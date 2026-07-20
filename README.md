# Swedish Women's Suffrage Petition Signatories, 1913–14

## Overview

This repository contains transcribed and harmonized data from the nationwide Swedish petition for women's political suffrage and eligibility for office in 1913–14. The petition was organized by the National Association for Women's Suffrage in Sweden (*Landsföreningen för kvinnans politiska rösträtt*, LKPR) and submitted to the Swedish Parliament in 1914.

The source material was digitized through *I demokratins namn: kvinnorna som krävde rösträtt* on [FromThePage.com](https://fromthepage.com/), using scanned archival volumes from the National Archives of Sweden. The [source images and collaborative transcriptions are available here](https://fromthepage.com/riksarkivet/i-demokratins-namn).

Version 0.1 contains 18,733 petition lists and 350,092 transcribed rows after removing reviewed duplicate scans, blank source pages, and crossed-out or non-person rows.

## Citation

If you use this data, please cite:

```bibtex
@dataset{bounadi_folkestad_2026_suffrage,
  title   = {Swedish Women's Suffrage Petition Signatories, 1913–14},
  author  = {Bounadi, Monir and Folkestad, Mattias},
  year    = {2026},
  version = {0.1}
}
```

## Data features

- Covers roughly 350,000 signatures, about 18 percent of women aged over 18 in Sweden at the time.
- Provides petition-list and row-level files linked by `image_id`.
- Retains cleaned transcriptions alongside harmonized research variables.
- Includes harmonized counties, historical localities, and coordinates.
- Harmonizes contributions in Swedish kronor (SEK).
- Infers IPUMS-style marital status from titles.
- Classifies occupations using SwedPop HISCO codes.

## Data construction

The data were built from a June 17, 2026 export of completed FromThePage transcriptions, with later manual review of selected pages. The construction has four main steps:

1. Combine and clean the FromThePage CSV exports.
2. Preserve all transcribed fields after Unicode normalization and whitespace trimming.
3. Harmonize counties, localities, name counts, contributions, titles, occupations, marital status, and coordinates.
4. Classify occupations with the SwedPop HISCO coding scheme.

Occupational titles were matched to a SwedPop code-list workbook supplied to the authors. The workbook is not redistributed here. The public SwedPop documentation used for coding is included unchanged in `documentation/hisco/`.

Key measurement notes:

- `entry_id` identifies a row in this release, not a unique person.
- `name_count` is a reviewed list-level count and need not equal the number of rows in `individuals.csv`.
- Coordinates refer to the locality heading on the petition list, not to individual street addresses.
- Missing contributions are unknown, not zero.
- HISCO code `99999` denotes an unclear occupation following SwedPop. Codes `-1` and `-2` denote no recorded current occupation and explicit absence of occupation, respectively.

## Getting started

Download the repository and use the two CSV files in `data/`:

| File | Unit of observation | Rows |
|---|---|---:|
| `data/lists.csv` | Petition list | 18,733 |
| `data/individuals.csv` | Row on petition list | 350,092 |

The files merge many-to-one using `image_id`.

Important variables in `lists.csv` include:

- `image_id`: petition-list identifier and merge key.
- `source_url`: link to the source image and transcription.
- `county`, `place`: harmonized county and locality.
- `name_count`: harmonized list-level count of names.
- `total_contribution_sek`: harmonized list contribution in SEK.
- `place_latitude`, `place_longitude`: locality coordinates.

Important variables in `individuals.csv` include:

- `entry_id`: row identifier in this release.
- `first_name_transcribed`, `last_name_transcribed`: names as transcribed.
- `title_transcribed`, `occupation_transcribed`, `address_transcribed`: source fields as transcribed.
- `title_harmonized`, `occupation_harmonized`: harmonized title and occupation strings.
- `marital_status`: IPUMS-style marital-status code.
- `contribution_sek`: harmonized individual contribution in SEK.
- `hisco_code`, `hisco_label`, `hisco_classification`: SwedPop HISCO assignment.

All files are UTF-8 encoded. Empty CSV cells represent missing values.

### Code examples

Run these examples from the repository root.

<details open>
<summary>Python</summary>

```python
import pandas as pd

lists = pd.read_csv("data/lists.csv")
individuals = pd.read_csv("data/individuals.csv")

data = individuals.merge(lists, on="image_id", how="left", validate="many_to_one")
```

</details>

<details>
<summary>R</summary>

```r
lists <- read.csv("data/lists.csv", fileEncoding = "UTF-8")
individuals <- read.csv("data/individuals.csv", fileEncoding = "UTF-8")

data <- merge(individuals, lists, by = "image_id", all.x = TRUE, sort = FALSE)
```

</details>

<details>
<summary>Stata</summary>

```stata
import delimited "data/lists.csv", clear varnames(1) encoding("utf-8")
isid image_id
tempfile lists
save `lists'

import delimited "data/individuals.csv", clear varnames(1) encoding("utf-8")
isid entry_id
merge m:1 image_id using `lists', keep(master match) nogen
```

</details>

## License

The data are released under the [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) public-domain dedication. Scientific citation is appreciated.

The bundled SwedPop PDF is third-party documentation included unchanged for reproducibility. It remains attributable to SwedPop/CEDAR and its named author.

## Version history

### Version 0.1

Initial public research release based on the June 17, 2026 export of the first set of complete transcriptions from FromThePage.
