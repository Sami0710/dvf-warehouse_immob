-- Volume de ventes et prix au m² médian, par mois et type de bien.
select
    d.annee_mois,
    d.annee,
    d.mois,
    f.type_local              as type_bien,
    count(*)                  as nb_ventes,
    round(median(f.prix_m2))  as prix_m2_median
from {{ ref('fct_ventes') }} f
join {{ ref('dim_date') }} d on d.date_jour = f.date_vente
group by 1, 2, 3, 4
order by d.annee_mois, type_bien
