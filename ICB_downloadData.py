import re
import io
import os
import gzip
import shutil
import multiprocessing

import tqdm
import requests

from bs4 import BeautifulSoup


regex = re.compile(r'NeuroVault: sub-(?P<subject>\d\d)_ses-(?P<session>\d\d)_(?P<title>.*)')

def decompress_to_path(filepath, url):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    response = requests.get(url)
    decompressed_file = gzip.GzipFile(fileobj=io.BytesIO(response.content))

    with open(filepath, 'wb') as out_file:
        out_file.write(decompressed_file.read())

    del response
    del decompressed_file

def process_id(img_id):
    try:
        url = f"https://neurovault.org/images/{img_id}/"
        response = requests.get(url)
        soup = BeautifulSoup(response.text)
        if not soup:
            print(f"Could not parse HTML for url: {url}")
            return


        img_url = soup.find("meta", attrs={"name":"file"}).attrs["content"]
        title_raw = soup.find("title").text
        match = re.match(regex, title_raw)
        if not match:
            print(f"Could not find regex match for title: {title_raw}")
            return

        subject = match.group("subject")
        session = match.group("session")
        title = match.group("title")

        basepath = "/Users/mchamberlin/Documents/mypython/cerebellum_cognition/data"
        filename = f"s{subject}/sess{session}-{title}.nii"
        filepath = os.path.join(basepath, filename)

        decompress_to_path(filepath, img_url)

    except Exception as e:
        print(f"Error downloading image {img_id}: {str(e)}")


ids = range(40012, 42211)

with multiprocessing.Pool(processes=8) as p:
    r = list(tqdm.tqdm(p.imap(process_id, ids), total=len(ids)))

