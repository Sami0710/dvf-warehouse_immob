-- Dimension type de bien (petite table : Maison, Appartement).
select distinct
    type_local as type_bien
from {{ ref('fct_ventes') }}
