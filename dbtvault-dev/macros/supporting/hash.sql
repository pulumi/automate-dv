/*
 *  Copyright (c) Business Thinking Ltd. 2019-2022
 *  This software includes code developed by the dbtvault Team at Business Thinking Ltd. Trading as Datavault
 */

{%- macro hash(columns=none, alias=none, is_hashdiff=false) -%}

    {%- if is_hashdiff is none -%}
        {%- set is_hashdiff = false -%}
    {%- endif -%}

    {{- adapter.dispatch('hash', 'dbtvault')(columns=columns, alias=alias, is_hashdiff=is_hashdiff) -}}

{%- endmacro %}

{%- macro default__hash(columns, alias, is_hashdiff) -%}

{%- set hash = var('hash', 'md5') -%}
{%- set concat_string = var('concat_string', '||') -%}
{%- set null_placeholder_string = var('null_placeholder_string', '^^') -%}

{%- set hash_alg = dbtvault.select_hash_alg(hash) -%}

{%- set standardise = dbtvault.standard_column_wrapper() %}

{#- Alpha sort columns before hashing if a hashdiff -#}
{%- if is_hashdiff and dbtvault.is_list(columns) -%}
    {%- set columns = columns|sort -%}
{%- endif -%}

{#- If single column to hash -#}
{%- if columns is string -%}
    {%- set column_str = dbtvault.as_constant(columns) -%}
    {%- set escaped_column_str = dbtvault.escape_column_names(column_str) -%}

    {{ hash_alg | replace('[HASH_STRING_PLACEHOLDER]', standardise | replace('[EXPRESSION]', escaped_column_str)) }} AS {{ dbtvault.escape_column_names(alias) | indent(4) }}

{#- Else a list of columns to hash -#}
{%- else -%}

    {%- set all_null = [] -%}
    {%- set processed_columns = [] -%}

    {%- for column in columns -%}
        {%- set column_str = dbtvault.as_constant(column) -%}
        {%- set escaped_column_str = dbtvault.escape_column_names(column_str) -%}

        {%- set column_expression = dbtvault.null_expression(escaped_column_str) -%}

        {%- do all_null.append(null_placeholder_string) -%}
        {%- do processed_columns.append(column_expression) -%}

    {% endfor -%}

    {% if not is_hashdiff -%}

        {%- set concat_sql -%}
        NULLIF({{ dbtvault.concat_ws(processed_columns, separator=concat_string) -}} {{ ', ' -}}
               '{{ all_null | join(concat_string) }}')
        {%- endset -%}

        {%- set hashed_column -%}
        {{ hash_alg | replace('[HASH_STRING_PLACEHOLDER]', concat_sql) }} AS {{ dbtvault.escape_column_names(alias) }}
        {%- endset -%}

    {%- else -%}
        {% if dbtvault.is_list(processed_columns) and processed_columns | length > 1 %}
            {%- set hashed_column -%}
                {{ hash_alg | replace('[HASH_STRING_PLACEHOLDER]', dbtvault.concat_ws(processed_columns, separator=concat_string)) }} AS {{ dbtvault.escape_column_names(alias) }}
            {%- endset -%}
        {%- else -%}
            {%- set hashed_column -%}
                {{ hash_alg | replace('[HASH_STRING_PLACEHOLDER]', processed_columns[0]) }} AS {{ dbtvault.escape_column_names(alias) }}
            {%- endset -%}
        {%- endif -%}
    {%- endif -%}

    {{ hashed_column }}

{%- endif -%}

{%- endmacro -%}


{%- macro bigquery__hash(columns, alias, is_hashdiff) -%}

    {{ dbtvault.default__hash(columns=columns, alias=alias, is_hashdiff=is_hashdiff) }}

{%- endmacro -%}


{%- macro sqlserver__hash(columns, alias, is_hashdiff) -%}

    {{ dbtvault.default__hash(columns=columns, alias=alias, is_hashdiff=is_hashdiff) }}

{%- endmacro -%}


{%- macro postgres__hash(columns, alias, is_hashdiff) -%}

    {{ dbtvault.default__hash(columns=columns, alias=alias, is_hashdiff=is_hashdiff) }}

{%- endmacro -%}


{%- macro databricks__hash(columns, alias, is_hashdiff) -%}

    {{ dbtvault.default__hash(columns=columns, alias=alias, is_hashdiff=is_hashdiff) }}

{%- endmacro -%}