"""Extract + Load : télécharge les ventes DVF, ne garde que le Grand Est
(hors Alsace-Moselle, absente de DVF à cause du livre foncier local),
et charge le tout dans DuckDB en texte brut. Le nettoyage/typage est fait ensuite par dbt."""
import os
import urllib.request

import duckdb

YEARS = [y.strip() for y in os.getenv("INGEST_YEARS", "2023,2024").split(",") if y.strip()]
# Grand Est hors Alsace-Moselle (67, 68, 57 ne figurent pas dans DVF)
DEPTS = ("08", "10", "51", "52", "54", "55", "88")
DB_PATH = os.getenv("DUCKDB_PATH", "warehouse/dvf.duckdb")
URL = "https://files.data.gouv.fr/geo-dvf/latest/csv/{year}/full.csv.gz"

# Colonnes utiles parmi les 40 du fichier source
COLS = [
    "id_mutation", "date_mutation", "nature_mutation", "valeur_fonciere",
    "code_postal", "code_commune", "nom_commune", "code_departement",
    "type_local", "surface_reelle_bati", "nombre_pieces_principales",
    "surface_terrain", "longitude", "latitude",
]


def main() -> None:
    con = duckdb.connect(DB_PATH)
    con.execute("DROP TABLE IF EXISTS raw_ventes")
    cols_def = ", ".join(f'"{c}" VARCHAR' for c in COLS)
    con.execute(f"CREATE TABLE raw_ventes ({cols_def}, source_year INTEGER, loaded_at TIMESTAMP)")
    select_cols = ", ".join(f'"{c}"' for c in COLS)
    dept_list = ", ".join(f"'{d}'" for d in DEPTS)

    for year in YEARS:
        url = URL.format(year=year)
        tmp = f"/tmp/dvf_{year}.csv.gz"
        print(f"[{year}] téléchargement...", flush=True)
        urllib.request.urlretrieve(url, tmp)
        print(f"[{year}] chargement du Grand Est dans DuckDB...", flush=True)
        con.execute(f"""
            INSERT INTO raw_ventes
            SELECT {select_cols}, {int(year)} AS source_year, now() AS loaded_at
            FROM read_csv('{tmp}', all_varchar=true, header=true,
                          quote='"', escape='"', ignore_errors=true)
            WHERE code_departement IN ({dept_list})
        """)
        os.remove(tmp)
        n = con.execute(
            "SELECT count(*) FROM raw_ventes WHERE source_year = ?", [int(year)]
        ).fetchone()[0]
        print(f"[{year}] {n:,} lignes Grand Est chargées", flush=True)

    total = con.execute("SELECT count(*) FROM raw_ventes").fetchone()[0]
    print(f"Total raw_ventes : {total:,} lignes", flush=True)
    con.close()


if __name__ == "__main__":
    main()
