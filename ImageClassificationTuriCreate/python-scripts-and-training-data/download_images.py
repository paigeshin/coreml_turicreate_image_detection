import os
import requests

def make_directories(directory_name): 
    if not os.path.exists(directory_name):
        os.makedirs(directory_name)
        print('Directory has been created!')
    else: 
        print('Directory already exists!')

def download_and_save_images(url, directory_name):
    list = requests.get(url).text.split('\r\n')[:50]

    for url in list: 
        filename = os.path.basename(url)
        print(filename)
        try: 
            with open(f"{directory_name}/{filename}","wb") as file_object: 
                file_object.write(requests.get(url, timeout=1).content)
        except: 
            print(f"Error downloading {filename}")
            continue 

cat_url = "http://image-net.org/api/text/imagenet.synset.geturls?wnid=n02123045"
dog_url = "http://image-net.org/api/text/imagenet.synset.geturls?wnid=n02111277"

current_directory = os.getcwd() 
cats_directory = current_directory + "/train/cats"
dogs_directory = current_directory + "/train/dogs"

make_directories(cats_directory) 
make_directories(dogs_directory)

download_and_save_images(cat_url,cats_directory)
download_and_save_images(dog_url, dogs_directory)