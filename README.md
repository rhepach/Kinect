# Kinect - body posture analysis

One Paragraph of project description goes here.

Contains all relevating scripts to run, process, and analyze posture data gathered from our Kinect-studies.
Each script is named after the current project it is used in and after the processing step it reflects in the overall process.

## Getting Started

### Prerequisites

Kinect-Prerequisites (Versions? Anschluss an PC, ...)

Additionally required toolbox for the recording script: Image Acquisition Toolbox.

In order to check if the Image Acquisition Toolbox is installed type the following code in the MATLAB command window.

```Matlab
license('test', 'Image_Acquisition_Toolbox')
```

The Processing Script runs in Windows and Mac OS, whereas the Recording Script only runs in Windows so far.

## Usage

### Step 1
Collect data by using the recording script to run your Kinect and extract .mat files for each frame.

### Step 2
Run the MATLAB processing script to extract body posture information, images or delete data to reduce file size.

The image below shows the processing GUI with all options to chose for processing the data.

![Image of the ProcessingGUI](ProcessingGUI.PNG)

## Support
Tell people where they can go to for help. A chat room, an email address, etc.

? Contact: robert.hepach@uni-leipzig.de

## Roadmap
list ideas for releases in the future.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

The processing script is part of an ongoing line of research and it is continuously updated. Those familiar with Matlab will notice redundancies in the code and room for improvement.

Pull requests are welcome. You are, of course, free to make changes to the script for your own purposes but you do so at your own risk.
For major changes, please open an issue first to discuss what you would like to change.

## Authors and acknowledgment
Processing Script:
- written by Anja Neumann.
- maintained by Robert Hepach.

Recording Script:
- xyz

If you use the script or find it generally useful kindly support our research by citing our work.
-  Hepach, R., Vaish, A., & Tomasello, M. (2015). Novel paradigms to measure variability of behavior in early childhood: posture, gaze, and pupil dilation. _Frontiers in psychology, 6_, 858. [https://doi.org/10.3389/fpsyg.2015.00858](https://doi.org/10.3389/fpsyg.2015.00858)
- Hepach, R., Vaish, A., & Tomasello, M. (2017). The fulfillment of others’ needs elevates children’s body posture. _Developmental psychology, 53(1)_, 100. [http://dx.doi.org/10.1037/dev0000173](http://dx.doi.org/10.1037/dev0000173)
