-- Table de faits : une ligne = la vente d'UN logement (maison ou appartement).
with ventes as (
    select *
    from {{ ref('stg_ventes') }}
    where nature_mutation = 'Vente'
      and type_local in ('Maison', 'Appartement')
      and valeur_fonciere > 0
      and surface_bati > 0
),

-- On ne garde que les mutations portant sur un seul logement : sinon la valeur
-- foncière (globale à la mutation) fausserait le prix au m².
mono_logement as (
    select id_mutation
    from ventes
    group by id_mutation
    having count(*) = 1
)

select
    v.id_mutation,
    v.date_vente,
    v.code_commune,
    v.type_local,
    v.valeur_fonciere,
    v.surface_bati,
    v.nb_pieces,
    round(v.valeur_fonciere / v.surface_bati) as prix_m2
from ventes v
join mono_logement using (id_mutation)
-- Écarte les valeurs aberrantes (erreurs de saisie, ventes symboliques)
where round(v.valeur_fonciere / v.surface_bati) between 200 and 20000
