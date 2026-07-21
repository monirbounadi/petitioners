version 16
clear all
set more off

/*
Study the v0.1 release only.

This do-file reads the public CSV files and reports descriptive tables and
basic consistency checks. It does not rebuild, harmonize, overwrite, or export
any release data.

Usage:
    do study_release.do

Run it either from the repository root or from the parent folder containing
github-repository/.
*/

capture confirm file "data/individuals.csv"
if !_rc {
    local data_dir "data"
}
else {
    capture confirm file "github-repository/data/individuals.csv"
    if !_rc {
        local data_dir "github-repository/data"
    }
    else {
        di as error "Could not find data/individuals.csv or github-repository/data/individuals.csv"
        exit 601
    }
}

tempfile individuals lists

di as txt _newline "Reading public release files from: `data_dir'"

import delimited using "`data_dir'/individuals.csv", clear varnames(1) stringcols(_all) encoding("UTF-8")
compress

foreach v in row_number has_name marital_status birth_year age_years contribution_sek hisco_code {
    capture confirm variable `v'
    if !_rc {
        destring `v', replace force
    }
}

save `individuals'

import delimited using "`data_dir'/lists.csv", clear varnames(1) stringcols(_all) encoding("UTF-8")
compress

foreach v in image_position name_count total_contribution_sek place_latitude place_longitude {
    capture confirm variable `v'
    if !_rc {
        destring `v', replace force
    }
}

save `lists'

di as txt _newline "=============================="
di as txt "List-level file"
di as txt "=============================="
use `lists', clear
describe
count
isid image_id

di as txt _newline "County"
tab county, missing

di as txt _newline "Geocoding method"
tab geocode_method, missing

di as txt _newline "Name count"
summarize name_count, detail
tab name_count if name_count <= 30, missing
count if missing(name_count) | name_count <= 0
if r(N) {
    di as error "Lists with missing or non-positive name_count:"
    list image_id source_url county place name_count other_notes_transcribed if missing(name_count) | name_count <= 0, noobs abbreviate(32)
}

di as txt _newline "Total contribution, SEK"
summarize total_contribution_sek, detail
tab total_contribution_source, missing
count if missing(total_contribution_sek)
if r(N) {
    di as txt "Lists with missing total_contribution_sek:"
    list image_id source_url county place total_kronor_transcribed total_ore_transcribed other_notes_transcribed if missing(total_contribution_sek), noobs abbreviate(32)
}

di as txt _newline "Coordinates"
count if missing(place_latitude) | missing(place_longitude)
if r(N) {
    di as txt "Lists with missing coordinates:"
    list image_id source_url county place place_latitude place_longitude geocode_method if missing(place_latitude) | missing(place_longitude), noobs abbreviate(32)
}

di as txt _newline "=============================="
di as txt "Individual-level file"
di as txt "=============================="
use `individuals', clear
describe
count
isid entry_id

di as txt _newline "Rows with a transcribed name"
tab has_name, missing

di as txt _newline "Marital status"
tab marital_status marital_status_label, missing

di as txt _newline "HISCO classification"
tab hisco_classification, missing

di as txt _newline "HISCO source"
tab hisco_source, missing

di as txt _newline "HISCO labels, sorted by frequency"
tab hisco_label, sort missing

di as txt _newline "Occupation harmonized, sorted by frequency"
tab occupation_harmonized, sort missing

di as txt _newline "Title harmonized, sorted by frequency"
tab title_harmonized, sort missing

di as txt _newline "Birth year and age"
summarize birth_year age_years, detail

di as txt _newline "Individual contribution, SEK"
summarize contribution_sek, detail
tab contribution_source, missing
tab contribution_kronor_field_interpreted_as_ore, missing
count if missing(contribution_sek)
if r(N) {
    di as txt "Individuals with missing contribution_sek:"
    list entry_id image_id row_number first_name_transcribed last_name_transcribed contribution_kronor_transcribed contribution_ore_transcribed contribution_sek if missing(contribution_sek), noobs abbreviate(32)
}

di as txt _newline "=============================="
di as txt "Linking lists and individuals"
di as txt "=============================="
merge m:1 image_id using `lists', keep(master match) nogen keepusing(source_url county place name_count total_contribution_sek place_latitude place_longitude)

count if missing(source_url)
if r(N) {
    di as error "Individuals without a matching petition list:"
    list entry_id image_id row_number first_name_transcribed last_name_transcribed if missing(source_url), noobs abbreviate(32)
}
else {
    di as result "Every individual row links to a petition list by image_id."
}

bysort image_id: egen rows_with_name = total(has_name == 1)
bysort image_id: gen image_tag = _n == 1
gen name_count_diff = rows_with_name - name_count if image_tag

di as txt _newline "Difference between release name_count and rows with a name"
tab name_count_diff if image_tag, missing

count if image_tag & abs(name_count_diff) > 5 & !missing(name_count_diff)
if r(N) {
    di as txt "Petition lists where abs(rows_with_name - name_count) > 5:"
    list image_id source_url county place name_count rows_with_name name_count_diff if image_tag & abs(name_count_diff) > 5 & !missing(name_count_diff), noobs abbreviate(32)
}

di as txt _newline "Done. No release files were changed."
