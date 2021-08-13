import math
import cv2
from cv2 import *
from scipy.signal import medfilt2d
import numpy as np
import os


# Normalize image in [0, 1]
def im2double(im):
    min_val = np.min(im.ravel())
    max_val = np.max(im.ravel())
    if max_val - min_val != 0:
        out = (im.astype('float') - min_val) / (max_val - min_val)
    else:
        out = im
    return out


# Replace your path here
folder_img = '/home/reyhane/Desktop/dataset/MT_Free/Imgs'
folder_mask = '/home/reyhane/Desktop/dataset/MT_Free/Masks'

filename = os.listdir(folder_img)

for k in filename:
    # Load image and it's mask
    I = im2double(imread(os.path.join(folder_img, k.split('.')[0] + '.jpg'), 0))
    Mask = im2double(imread(os.path.join(folder_mask, k.split('.')[0] + '.png'), 0))

    # Image enhancement:
    # Ia(i, j) = (I(i,j)*0.5bm) / Im(i, j)
    # where i and j denote the position of the target pixel,
    # Ia denotes the image after the correction,
    # I denotes the image before the correction,
    # Im denotes the result of applying the median filter to the image before the correction,
    # bm denotes the maximum pixel value (here is 1)

    Im = medfilt2d(I, 41)

    Ia = np.zeros(I.shape)
    T = np.zeros(I.shape)

    h, w = I.shape

    for i in range(h):
        for j in range(w):
            Ia[i, j] = (I[i, j] * 0.5) / (Im[i, j] + math.pow(2, -25))
            # Thresholding image to detect defect
            if Ia[i, j] <= 0.35:
                T[i, j] = 1

    # Median filter and morphology to remove unwanted pixels
    T = medfilt2d(T, 3)
    SE = getStructuringElement(MORPH_RECT, (3, 3))
    O = morphologyEx(T, MORPH_OPEN, SE)

    # Show final result
    imshow('Result', hconcat([I, Ia, O]))
    waitKey(0)
destroyWindow("finish")
