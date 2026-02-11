/*
 * Copyright (c) Business Thinking Ltd. 2019-2026
 * This software includes code developed by the AutomateDV (f.k.a dbtvault) Team at Business Thinking Ltd. Trading as Datavault
 */

{%- macro binary_ghost(alias, hash) -%}
    {%- set hash = hash | lower -%}

    {{ adapter.dispatch('binary_ghost', 'automate_dv')(alias=alias, hash=hash) }}
{%- endmacro -%}

{%- macro default__binary_ghost(alias, hash) -%}
    {% if "HASHDIFF" in alias %}
        {{
            automate_dv.cast_binary(
                column_str=ghost_record_id(), alias=alias, quote=true
            )
        }}
    {% else %} '{{ ghost_record_id() }}' as {{ alias }}
    {% endif %}
{%- endmacro -%}

{%- macro ghost_record_id() -%}
    {{ modules.itertools.repeat("0", 56) | join("") }}
{%- endmacro -%}


