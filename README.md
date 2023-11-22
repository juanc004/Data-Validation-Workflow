# Data-Validation-Workflow

## Project Overview
This R program is aimed at ensuring data quality assurance for the (SWCC) program. It facilitates interactions with the Smartabase platform to seamlessly pull data, identify and rectify potential data discrepancies, and push the refined data back to the platform.

## Table of Contents
- [Features](#features)
- [Dependencies](#dependencies)
- [Setup](#setup)
- [Usage](#usage)
- [Repository Structure](#repository-structure)
- [Known Issues](#known-issues)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Features
- Data Retrieval: Extracts data from specified forms in Smartabase.
- Logging Mechanism: Provides timely notifications of any potential data gaps or anomalies.
- Data Aggregation: Assimilates and structures data from a variety of forms.
- Data Renaming: Modifies data field names to synchronize with the target forms in Smartabase.
- Data Pushing: Sends cleaned and updated data back to Smartabase.

## Dependencies
- R and RStudio
- R packages: neon, dplyr, tidyr

## Setup
1. Clone the repository to your local machine.
2. Install R and RStudio.
3. Open RStudio and install the necessary R packages using the command: `install.packages(c("neon", "dplyr", "tidyr"))`.

## Usage
1. Set your desired date range in the "Date Configuration" section of the respective script.
2. Run the chosen script in RStudio (either `DataQA_script.R` or `admin_push_script.R`).
3. Monitor the console for logs or notifications.

## Repository Structure
- `DataQA_script.R`: Contains procedures for general data quality checks and updates for SWCC data.
- `admin_push_script.R`: Specialized script for pushing administrative details and AFSC tracking data to Smartabase.

## Known Issues
None as of the last update. 

## Future Enhancements
- Integration with other data sources.

## Contributing
Interested in contributing? Fork the repository, make your changes, and submit a pull request. Ensure your changes are well documented.

## License
This project is licensed under the MIT License.

