# بسم الله الرحمن الرحيم
# la ilaha illa Allah Mohammed Rassoul Allah

import requests

print("بسم الله الرحمن الرحيم")
print("this script is to download all the images from the website")

pages_count = 604

for i in range(1, pages_count):
    download_url = 'https://easyquran.com/wp-content/uploads/2022/10/' + str(i) + '-scaled.jpg'
    image_output_path = "src/res/" + str(i) + "-scaled.jpg"

    print("alhamdo li Allah will download image from '" + download_url + "' to '" + image_output_path + "'")

    img_data = requests.get(download_url).content
    f = open(image_output_path, "wb")
    f.write(img_data)
    f.close()

print('alhamdo li Allah done downloading images')
