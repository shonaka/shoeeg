# Sho's personal EEG processing library

Some codes in MATLAB to process EEG data. Personal library built to use functions and classes mainly from EEGLAB.

## Getting Started

If you are starting to clean the EEG data, start by looking into the "preprocess" folder.

### Prerequisites

MATLAB 2015 or above required.
* Signal processing toolbox
* Parallel computing toolbox
* [EEGLAB](https://sccn.ucsd.edu/eeglab/) - open source EEG processing toolbox
* [Plugins in EEGLAB](https://sccn.ucsd.edu/wiki/EEGLAB_Plugins) - please refer to each classes that use plugins in eeglab and make sure to download and install before utilizing them.

## Authors

* **Sho Nakagome**

## Current folder structures

* dependencies - some files and functions used in the library but not written by me.
* fileIO - some importing and exporting functions.
* plot - some classes useful for plotting nice figures in MATLAB.
* postprocess - some classes and functions used during post processing (e.g. source localization) in EEG study.
* preprocess - some classes and functions used for pre processing in EEG study to clean artifacts (e.g. eye related, muscle related, motion related, etc).
* utility - other stuffs.

## License

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


## Acknowledgments

* Trieu Phat Luu
* EEGLAB developers
