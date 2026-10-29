-- Dimension date : une ligne par jour de vente, avec les découpages utiles.
with jours as (
    select distinct date_vente as date_jour
    from {{ ref('fct_ventes') }}
)

select
    date_jour,
    extract(year    from date_jour) as annee,
    extract(month   from date_jour) as mois,
    extract(quarter from date_jour) as trimestre,
    strftime(date_jour, '%Y-%m')    as annee_mois
from jours
