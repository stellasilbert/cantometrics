
# install python venv and install python libraries
env:
	python3 -m venv env
	./env/bin/python3 ./env/bin/pip3 install -r requirements.txt

update: env
	./env/bin/python3 ./env/bin/pip3 install --upgrade -r requirements.txt


all: download process process2 test

help:
	@printf "\nIf you are an authenticated user and you want to update the data from Google Drive, run: make download\n\n"
	@printf "To build the dataset into CLDF format, run: make process (this takes some time), then make process2 (this does not take very long) \n\n"
	@printf "To validate the dataset, run: make test \n\n"

download: env
	@printf "Collecting data from google drive is only available to authenticated users."
	mkdir -p raw/
	./env/bin/python3 download_googledrive.py

process: env
	mkdir -p cldf/
	mkdir -p logs/
	@printf "Convert data to long format"
	./env/bin/python3 to_long.py
	@printf "Backtransform codes to single level codes"
	./env/bin/python3 recode.py #2>&1 | tee logs/recode.log

process2: env
	cp raw/societies.csv cldf/
	cp raw/songs.csv cldf/
	./env/bin/python3 rename_andsubset.py

test: env
	./env/bin/cldf validate ./cldf/StructureDataset-metadata.json 2>&1 | tee logs/cldf.log
	./env/bin/python3 -m pytest

clean:
	rm -rf raw/ logs/ cldf/data.csv cldf/decoded_data.csv cldf/societies.csv cldf/songs.csv

