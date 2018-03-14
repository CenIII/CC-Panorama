# CC-Panorama
An multi-image stitching algorithm that can deal with outlier images.

## Features
- Allow as many input images as possible.
- Allow outlier images (<20% of the total)
- Automatically determine the central image.
- Automatically determine the order of merging.

## Example Results
### Example 1: *yellowstone4*
#### Input images
![img](https://github.com/CenIII/CC-Panorama/blob/master/rdm/snapshot1.png)

#### Output image
![img](https://github.com/CenIII/CC-Panorama/blob/master/rdm/yellowstone4_10imgs.png)

### Example 2: *intersection*
#### Input images
![img](https://github.com/CenIII/CC-Panorama/blob/master/rdm/snapshot2.png)

#### Output image
![img](https://github.com/CenIII/CC-Panorama/blob/master/rdm/intersection_8imgs.png)

## How to run it

  1. Create a new directory in ./data/ and put the input images into it.
  ```
    mkdir ./data/new_imgs
    mv your_img_path ./data/new_imgs
  ```

  2. Rename your images from 1 to the # of images like "1.jpg", "2.jpg" ... "15.jpg".

  3. Run in Matlab console
  ```
    disp=1; %Display the final panorama.
    im_out=Multi_pano(new_imgs,disp);
  ```

## Brief Intro to the Algorithm
### 1. Feature extraction
- [x] Harris corner detector
- [x] SIFT descriptor

  For feature extraction, we use Harris corner detector to detect corners in both images, and then use SIFT method to convert all the feature points to 128-dimention vectors.

### 2. Putative matching

  - [x] 2-norm distance (btw SIFT descriptors)
  - [x] Lowe's law

### 3. Compute inlier matrix and transform-pair matrix

  - [x] RANSAC

  Using RANSAC algorithm for every pair of images we get:

  1) an ***inlier matrix*** where element (i,j) denotes RANSAC inliers
between image i and j, and

  2) a ***transform-pair matrix*** where element (i,j) contains the
transform matrix from image i to j.

  An example of an ***inlier matrix***:

| .    | 1.jpg| 2.jpg | 3.jpg | 4.jpg | 5.jpg  | 6.jpg  | 7.jpg | 8.jpg | 9.jpg  | 10.jpg | 11.jpg | 12.jpg |  
|----- |------|-----|-----|-----|-----|-----|-----|------|------|-----|---|---|
| 1.jpg| 0    | 489 | 216 | 135 | 71  | 15  | 543 | 1140 | 860  | 171 | 0 | 4 |
| 2.jpg| 489  | 0   | 453 | 309 | 234 | 170 | 314 | 458  | 353  | 355 | 4 | 4 |
| 3.jpg| 216  | 453 | 0   | 460 | 507 | 375 | 83  | 188  | 159  | 673 | 0 | 4 |
| 4.jpg| 135  | 309 | 460 | 0   | 405 | 443 | 15  | 127  | 79   | 521 | 0 | 4 |
| 5.jpg| 71   | 234 | 507 | 405 | 0   | 437 | 5   | 75   | 20   | 697 | 4 | 4 |
| 6.jpg| 15   | 170 | 375 | 443 | 437 | 0   | 5   | 12   | 5    | 438 | 4 | 0 |
| 7.jpg| 543  | 314 | 83  | 15  | 5   | 5   | 0   | 656  | 799  | 39  | 4 | 4 |
| 8.jpg| 1140 | 458 | 188 | 127 | 75  | 12  | 656 | 0    | 1033 | 156 | 4 | 4 |
| 9.jpg| 860  | 353 | 159 | 79  | 20  | 5   | 799 | 1033 | 0    | 100 | 4 | 0 |
| 10.jpg| 171  | 355 | 673 | 521 | 697 | 438 | 39  | 156  | 100  | 0   | 4 | 0 |
| 11.jpg| 0    | 4   | 0   | 0   | 4   | 4   | 4   | 4    | 4    | 4   | 0 | 4 |
| 12.jpg| 4    | 4   | 4   | 4   | 4   | 0   | 4   | 4    | 0    | 0   | 4 | 0 |

### 4. Eliminate outlier images

  By observing the inlier matrix we got from step 1, we can determine which images are outliers. Specifically, we first find the max number of inliers each image has with other images (find it in each row of the inlier matrix). It’s an outlier if this number is small (meaning no other images have enough inliers with it.). There are various way to define the "smallness" and the detailed implementation in this project is omitted here.

  After eliminating the outliers the ***inlier matrix*** becomes as follows:

  | .    | 1.jpg| 2.jpg | 3.jpg | 4.jpg | 5.jpg  | 6.jpg  | 7.jpg | 8.jpg | 9.jpg  | 10.jpg |
  |----- |------|-----|-----|-----|-----|-----|-----|------|------|-----|
  | 1.jpg| 0    | 489 | 216 | 135 | 71  | 15  | 543 | 1140 | 860  | 171 |
  | 2.jpg| 489  | 0   | 453 | 309 | 234 | 170 | 314 | 458  | 353  | 355 |
  | 3.jpg| 216  | 453 | 0   | 460 | 507 | 375 | 83  | 188  | 159  | 673 |
  | 4.jpg| 135  | 309 | 460 | 0   | 405 | 443 | 15  | 127  | 79   | 521 |
  | 5.jpg| 71   | 234 | 507 | 405 | 0   | 437 | 5   | 75   | 20   | 697 |
  | 6.jpg| 15   | 170 | 375 | 443 | 437 | 0   | 5   | 12   | 5    | 438 |
  | 7.jpg| 543  | 314 | 83  | 15  | 5   | 5   | 0   | 656  | 799  | 39  |
  | 8.jpg| 1140 | 458 | 188 | 127 | 75  | 12  | 656 | 0    | 1033 | 156 |
  | 9.jpg| 860  | 353 | 159 | 79  | 20  | 5   | 799 | 1033 | 0    | 100 |
  | 10.jpg| 171  | 355 | 673 | 521 | 697 | 438 | 39  | 156  | 100  | 0   |

  Notice that whether the outliers lie on the margins of the inlier matrix or not does not matter. It'll always output correct results even the outlier images are 5.jpg and 8.jpg, for example.

### 5. Select matchings

  Now given all the remaining images are valid for stitching, we have to determine all the match pairs of images. We take the following steps:

  1) First pick the max value of the inlier matrix as the first match pair. For example the index (1,7) (or (7,1) equivalently) is picked. Then set the max value to 0.

  2) Take image 1 and 7 as the initial “source”, each iteration we find one image that is closest to the “source”, and add it to the “source”. Then do this repeatedly. Specifically, we look at 1st and 7th row and find max value from the two rows, if (1,5) is the max, then image 5 is added to the “source”.

  3) Repeat step 2) for n-2 iterations, where n is the total number of valid images (without outlier images).

  4) Save all the matching pairs into a matching matrix, where element (i, j) being “1” means image i matches with image j.

  An example of ***matching matrix***:

| .    | 1.jpg| 2.jpg | 3.jpg | 4.jpg | 5.jpg  | 6.jpg  | 7.jpg | 8.jpg | 9.jpg  | 10.jpg |
|-----|---|---|---|---|---|---|---|---|---|---|
| 1.jpg| 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| 2.jpg| 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 3.jpg| 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 4.jpg| 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 |
| 5.jpg| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 6.jpg| 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |
| 7.jpg| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| 8.jpg| 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| 9.jpg| 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 |
| 10.jpg| 0 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |

  This is essentially a matrix representation of a undirected graph. You can traverse to any of other images from one image. Notice this matrix is symmetric too.

  Here we define an image i has k ***branches*** if at i'th row, there are k 1's. For example image 10.jpg has 3 branches out-reaching to all the other images.

### 6. Find central image

  After knowing which matches with which, we need to decide which one is the “central” image. Being a “central” image means that it will not perform any transformation (or perform transformation T = Identity matrix) in the final panorama, and the other images will perform a transformation with respect to this central image.

  The central image is an image that has nearly equal number of images distributed at each branch that connected to it. This can be calculated using the ***“matching matrix”*** we got from step 3. And “evenly distributed” means that the number at each branch has the smallest variance. For example if an image has three branches out reaching other images with 2 images at each branch, then the variance is 0 (since the var of [2,2,2] is 0), while in the mean time there must be an image which has only one branch and the number on that branch is 8, of which the variance is larger (the var of [8,0,0] is large obviously).

  By doing what we stated above, we can easily determine the central image.

### 7. Stitch images

  This step is to:

  1) First compute transform matrix (with respect to the central image we just found) for every image, and

  2) Second merged to the panorama canvas sequentially. The order of merging is not important since every image's transform matrix is known.

## Limitations and future work

- SIFT descriptor is currently not rotation invariant, meaning it'll fail when big rotation angle appears.
- Current implementation of RANSAC algorithm is too slow.
- Blending method is simple.
- Stitched image can be re-arranged using one of various map projections, e.g. Rectilinear, Cylindrical, etc. (This is to handle the wide-view case as in current implementation the wide-view case will result in extremely large panorama canvas.)
- There are some error propagation effects when calculating the transform matrix for each image. A new way to determine the transform matrices is in need.
