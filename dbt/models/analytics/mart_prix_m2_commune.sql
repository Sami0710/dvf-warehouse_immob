-- Prix au m² médian par commune et par année (communes avec assez de ventes).
select
    c.nom_commune,
    c.nom_departement,
    d.annee,
    count(*)                        as nb_ventes,
    round(median(f.prix_m2))        as prix_m2_median,
    round(avg(f.valeur_fonciere))   as prix_moyen
from {{ ref('fct_ventes') }} f
join {{ ref('dim_commune') }} c using (code_commune)
join {{ ref('dim_date') }} d on d.date_jour = f.date_vente
group by 1, 2, 3
having count(*) >= 5
order by d.annee, prix_m2_median desc
