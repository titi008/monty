from inline_snapshot import snapshot

import pydantic_monty


def test_repl_create_feed_stateful():
    repl, output = pydantic_monty.MontyRepl.create('counter = 0')

    assert output == snapshot(None)
    assert repl.feed('counter = counter + 1') == snapshot(None)
    assert repl.feed('counter') == snapshot(1)


def test_repl_dump_load_roundtrip():
    repl, _ = pydantic_monty.MontyRepl.create('x = 40')

    assert repl.feed('x = x + 1') == snapshot(None)

    serialized = repl.dump()
    loaded = pydantic_monty.MontyRepl.load(serialized)

    assert loaded.feed('x + 1') == snapshot(42)


def test_repl_create_with_start_inputs_feed_stateful():
    repl, output = pydantic_monty.MontyRepl.create(
        'counter = start',
        inputs=['start'],
        start_inputs={'start': 0},
    )

    assert output == snapshot(None)
    assert repl.feed('counter = counter + 1') == snapshot(None)
    assert repl.feed('counter') == snapshot(1)


def test_repl_busy_error():
    import pytest
    repl, output = pydantic_monty.MontyRepl.create('', external_functions=['func'])
    
    snapshot_output = repl.start('func()')
    assert isinstance(snapshot_output, pydantic_monty.MontyReplSnapshot)
    
    with pytest.raises(RuntimeError) as exc_info:
        repl.feed('1 + 1')
    assert str(exc_info.value) == snapshot('REPL is busy')

    with pytest.raises(RuntimeError) as exc_info:
        repl.start('1 + 1')
    assert str(exc_info.value) == snapshot('REPL is busy')
