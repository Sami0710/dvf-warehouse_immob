-- Dimension commune : une ligne par code commune.
select
    code_commune,
    any_value(nom_commune)       as nom_commune,
    any_value(code_departement)  as code_departement,
    case any_value(code_departement)
        when '08' then 'Ardennes'
        when '10' then 'Aube'
        when '51' then 'Marne'
        when '52' then 'Haute-Marne'
        when '54' then 'Meurthe-et-Moselle'
        when '55' then 'Meuse'
        when '88' then 'Vosges'
        else any_value(code_departement)
    end                          as nom_departement
from {{ ref('stg_ventes') }}
where code_commune is not null
group by code_commune
