-- Nettoyage et typage : le texte brut devient des vraies dates, nombres, etc.
with source as (
    select * from {{ source('raw', 'raw_ventes') }}
)

select
    id_mutation,
    cast(date_mutation as date)                        as date_vente,
    nature_mutation,
    try_cast(valeur_fonciere as double)                as valeur_fonciere,
    code_commune,
    nom_commune,
    code_departement,
    type_local,
    try_cast(surface_reelle_bati as integer)           as surface_bati,
    try_cast(nombre_pieces_principales as integer)     as nb_pieces,
    try_cast(surface_terrain as integer)               as surface_terrain,
    try_cast(longitude as double)                      as longitude,
    try_cast(latitude as double)                       as latitude,
    source_year
from source
where valeur_fonciere is not null
