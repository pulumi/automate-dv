/*
 *  Copyright (c) Business Thinking Ltd. 2019-2022
 *  This software includes code developed by the dbtvault Team at Business Thinking Ltd. Trading as Datavault
 */

{%- macro source_columns(source_relation=none) -%}

    {%- if source_relation -%}
        {%- set source_model_cols = adapter.get_columns_in_relation(source_relation) -%}

        {%- set column_list = [] -%}

        {%- for source_col in source_model_cols -%}
            {%- do column_list.append(source_col.column) -%}
        {%- endfor -%}

        {%- do return(column_list) -%}
    {%- endif %}

{%- endmacro -%}