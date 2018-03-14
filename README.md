# CC-Panorama
An multi-image stitching algorithm that's robust to outliers.

## Features
- Allow as many input images as possible.
- Allow outlier images (<20% of the total)
- Automatically determine the central image.
- Automatically determine the order of merging.

## Example Results
### Example 1: *yellowstone4*
#### Input images
![img](https://github.com/CenIII/CC-Panorama/tree/master/snapshot1.png)

#### Output image
![img](https://github.com/CenIII/CC-Panorama/blob/master/yellowstone4_10imgs.png)

### Example 2: *intersection*
#### Input images
![img](https://github.com/CenIII/CC-Panorama/tree/master/snapshot2.png)

#### Output image
![img](https://github.com/CenIII/CC-Panorama/blob/master/intersection_8imgs.png)


## Brief Intro to the Algorithm
### 1. Feature extraction

  For feature extraction, we use Harris corner detector to detect corners in both images, and then use SIFT method to convert all the feature points to 128-dimention vectors.

  - [x] Harris corner detector
  - [x] SIFT descriptor

### 2. Putative matching

  - [x] 2-norm distance (btw SIFT descriptors)
  - [x] Lowe's law

### 3. Compute inlier matrix and transform-pair matrix

  As the same with what we did in Part II, we first compute

  1) an **inlier matrix** where element (i,j) denotes RANSAC inliers
between image i and j, and

  2) a **transform-pair matrix** where element (i,j) contains the
transform matrix from image i to j.

  - [x] RANSAC

### 4. Eliminate outlier images

  By observing the inlier matrix we got from step 1, we can determine which images are outliers. Specifically, we first get the max number of inliers each image can get with other images. If this number is too small (meaning no other images have enough inliers with it.), then we can determine it’s an outlier.

### 5. Select matchings

  Now given all the remaining images are valid, we have to determine the all the match pairs of images. We take following steps:

  1) First pick the max value in the inlier matrix as the first match pair. For example the index (3,5) (or (5.3) equivalently) is picked. Then set the max value to 0.

  2) Take image 3 and 5 as the initial “source”, each iteration we find one image that is closest to the “source”, and add it to the “source”. Then do this repeatedly. Specifically we look at 3rd and 5th row and find max value from the two rows. For example if we find (3,7) is the max, then image 7 is added to the “source”.

  3) Repeat step 2) for n-2 iterations, where n is the total number of valid images (without outlier images).

  4) Save the matching pair as a “matching matrix”, where element (i, j) being “1” means image i matches with image j.

### 6. Find central image

  After knowing which matches with which, we need to decide which one is the “central” image. Being a “central” image means that it will not perform any transformation (or perform transformation T = Identity matrix) in the final panorama, and the other images will perform a transformation with respect to this central image.

  The central image is an image that has nearly equal number of images distributed at each branch that connected to it. This can be calculated using the “matching matrix” we got from step 3. And “evenly distributed” means that the number at each branch has the smallest variance. For example if an image has three branches out reaching other images with 2 images at each branch, then the variance is 0 (since the var of [2,2,2] is 0), while in the mean time there must be an image which has only one branch and the number on that branch is 8, of which the variance is larger (the var of [8,0,0] is large obviously).

  By doing what we stated above, we can easily determine the central image.

### 7. Stitch images

  This step is to:

  1) First compute transform matrix (with respect to the central image we just found) for every image, and

  2) Second merged to the panorama canvas sequentially. The order of merging is not important since every image's transform matrix is known.
