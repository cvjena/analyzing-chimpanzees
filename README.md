Summary
==============
This repository was developed to assist biologists at analyzing large image collections from chimpanzees (e.g., created with camera traps or by Zoo visitors). However,  algorithms are **not** specifically tuned to chimpanzees and are also applicable to other species.

The provided pipeline is intended to tackle a variety of questions, including

 - How many chimpanzees? *(Overall statistics)*
 - Where? *(Detection)*
 - Who? *(Identification + Novelty Detection)*
 - Which Age? *(Regression)*
 - Which Age Group? *(Classification)*
 - Which Gender? *(Classification)*
 
Below is a possible output of our entire pipeline.

![Results of our attribute prediction models](http://www.inf-cv.uni-jena.de/dbvmedia/de/Research/Fine_grained+Recognition/Freytag16_CFW_teaser_wide.png)
Requirements / Dependencies
==============
* the source code was developed in Matlab 8.2
* to use all currently supported features, the following libraries are required
  * Darknet (object detection)
  * Caffe (feature extraction, classification, regression)
  * LibLinear (classification)
  * gpml (regression)
* For a full list, see Installation guidelines below.
  

Installation
==============
* clone this repository (`git clone https://github.com/cvjena/analyzing-chimpanzees`)
* run `initWorkspaceChimpanzees.m` (libraries not found on your system are listed and possible code mirrors are suggested)
* Download the following repos, install them, and add their paths in  `initWorkspaceChimpanzees.m` (thereby we make their locations known to Matlab)
	* CaffeTools (https://github.com/cvjena/caffe_tools) 
	* LibLinearWrapper (https://github.com/cvjena/liblinearwrapper) 
	* gpml (http://www.gaussianprocess.org/gpml/code/matlab/doc/)
	* Darknet (https://github.com/cvjena/darknet)
	* Chimpanzee Face Dataset (https://github.com/cvjena/chimpanzee_face)
* Note that CaffeTools and LibLinearWrapper come with their own initWorkspace scripts, which also need to be adapted (require the correct pointers to Caffe and LibLinear at your system)
* Check that all 3rd-party libraries are installed andspecify their location in `initWorkspaceChimpanzees.m`
* Run `initWorkspaceChimpanzees.m` again.

Demos
==============
After you set up paths to 3rdparty libraries (see Installation), you can start to explore the repository! 
Before running the demos, make sure to download some pre-trained models from [download-from-google-drive](https://drive.google.com/file/d/0B6zfiWvz238dM1Q4Zk90WFMwT1k/view?usp=sharing) and to copy them to repo/demos/


 - **Analyzing cropped face images** (identification, age, age group, gender)
	 -  run `demo_czoo_face_analysis.m`
	 - note: requires pre-trained models 
 - **Perform an entire evaluation on CZoo** (identification, age, age group, gender)
	 - run `demo_czoo_evaluation.m`
 - **Visualize GT data on non-cropped images**
	 - run `demo_showing_ground_truth_data.m`
 - **Detect chimpanzees in non-cropped images**
	 - run `demo_only_detection.m`
	 - 	 note: requires pre-trained models 
 -  **Detect chimpanzees in non-cropped images + analyze detected faces**
	 - run `demo_detection_and_face_analysis.m`
	 - 	 note: requires pre-trained models 

![Results of `demo_czoo_face_analysis.m`](https://github.com/cvjena/analyzing-chimpanzees/tree/master/analyzing-chimpanzees/demo_czoo_face_analysis_output_2.png)



COPYRIGHT
=========
This software is licensed under the non-commercial license [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/). For usage beyond the scope of this license, please contact [Alex Freytag](http://www.inf-cv.uni-jena.de/freytag.html).
