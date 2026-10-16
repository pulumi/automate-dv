"""Run with python3 tests/test_sat_meta.py (requires Jinja2)."""

from itertools import product
from pathlib import Path
from types import SimpleNamespace

from jinja2 import Environment, StrictUndefined


def test_sat_meta():
    root = Path(__file__).resolve().parents[1]
    source = (root / "macros/tables/snowflake/sat.sql").read_text()
    previous = source.replace(
        "automate_dv.config_meta_get('apply_source_filter', false)",
        "config.get('apply_source_filter', false)",
    )
    assert source != previous
    env = Environment(undefined=StrictUndefined)
    for incremental, enabled, ghosts in product((False, True), repeat=3):
        context = dict(
            config={"meta": {"apply_source_filter": enabled}},
            model=SimpleNamespace(config=SimpleNamespace(materialized="incremental")),
            target=SimpleNamespace(type="snowflake"),
            this="satellite",
            ref=lambda name: name,
            var=lambda name, default: ghosts,
            automate_dv=SimpleNamespace(
                config_meta_get=lambda key, default: context["config"].get("meta", {}).get(key, default),
                expand_column_list=lambda columns: columns,
                prefix=lambda *args, **kwargs: "columns",
                multikey=lambda *args, **kwargs: "predicate",
                alias_all=lambda *args: "columns",
                create_ghost_record=lambda **kwargs: "SELECT ghost",
                is_any_incremental=lambda: incremental,
            ),
        )
        args = ("pk", "hashdiff", ["payload"], [], "effective", "loaded", "source", "staging")
        actual = env.from_string(source).make_module(context).default__sat(*args)
        context["config"] = {"apply_source_filter": enabled}
        expected = env.from_string(previous).make_module(context).default__sat(*args)
        assert actual == expected
        assert ("valid_stg AS (" in actual) == (incremental and enabled)
        assert ("ghost AS (" in actual) == ghosts

    context["config"] = {}
    assert "valid_stg AS (" not in env.from_string(source).make_module(context).default__sat(*args)


if __name__ == "__main__":
    test_sat_meta()
    print("Satellite meta config preserves SQL in all 8 filtering/ghost combinations.")
