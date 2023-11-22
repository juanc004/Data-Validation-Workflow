# Load necessary libraries
library(neon)
library(dplyr)
library(tidyr)

# ---------------------
# Credentials Management
# ---------------------
smartabase_user <- Sys.getenv("SMARTABASE_USER")
smartabase_pass <- Sys.getenv("SMARTABASE_PASS")

# ---------------------
# Date Configuration
# ---------------------

# If you want to use the current date, simply uncomment the following two lines:
# start_date <- format(Sys.Date(), "%d/%m/%Y")
 #end_date <- start_date

# If you want to manually set the date, uncomment and modify the following two lines:
start_date <- "01/01/2022"  # Replace with your desired start date in dd/mm/yyyy format
end_date <- "24/08/2023"    # Replace with your desired end date in dd/mm/yyyy format


# Define the group
group_name <- "SWCC Candidates"

# Define the 'pull_data_with_logging' function to retrieve and log data 
# based on a given form_name.
pull_data_with_logging <- function(form_name) {
  
  # Log a message indicating the start of the data pull for the specified form.
  cat("Attempting to pull data for form:", form_name, "\n")
  
  # Use 'tryCatch' to handle potential errors during the data pull.
  tryCatch({
    
    # Use the 'pull_smartabase' function to retrieve data based on the provided form_name.
    data <- pull_smartabase(
      form              = form_name,
      filter_user_key   = "group",
      filter_user_value = group_name,
      start_date        = start_date,
      end_date          = end_date
    )
    
    # Log a success message indicating the successful data pull for the specified form.
    cat("Successfully pulled data for form:", form_name, "\n")
    return(data)
    
  }, error = function(e) {
    # If there's an error during the data pull, log an error message with details.
    cat("Failed to pull data for form", form_name, ":", e$message, "\n")
    return(NULL)  # Return NULL if there's an error.
  })
}

# Use the 'pull_data_with_logging' function to retrieve data for each form. Repeat process for mulitple forms
candidate_details <- pull_data_with_logging("GPSA Candidate Details")
demographics <- pull_data_with_logging("GPSA Demographics")
course_tracking <- pull_data_with_logging("GPSA Course Tracking")

# Provide feedback on the number of records retrieved for each form
if (!is.null(candidate_details)) {
  cat("Number of records retrieved for GPSA Candidate Details:", nrow(candidate_details), "\n")
}
#GPSA Demographics
if (!is.null(demographics)) {
  cat("Number of records retrieved for GPSA Demographics:", nrow(demographics), "\n")
}

#GPSA Course Tracking
if (!is.null(course_tracking)) {
  cat("Number of records retrieved for GPSA Course Tracking:", nrow(course_tracking), "\n")
}

# ---------------------
# 2. IDENTIFY MISSING DATA
# ---------------------

# Define required fields for each form
required_candidate_fields <- c("First Name [Update]", "Last Name [Update]", "Date of Birth [Update]", "DOD ID Number [Change]", 
                               "USAF Status [Update]", "Rank [Update]")
required_demographics_fields <- c("Race", "Ethnicity")
required_course_fields <- c("4 Digit Course Number", "Entering Date")

# Process each dataset to identify missing values, convert all fields to character first to prevent issues with pivot_longer

# For Candidate Details
missing_candidate_details <- candidate_details %>%
  filter(`Correct Information?` == "No") %>%
  mutate(across(all_of(required_candidate_fields), as.character)) %>%
  filter(if_any(all_of(required_candidate_fields), is.na)) %>%
  select(user_id, about, everything()) %>%
  pivot_longer(cols = all_of(required_candidate_fields), names_to = "Field", values_to = "Value") %>%
  filter(is.na(Value)) %>%
  mutate(Form = "GPSA Candidate Details")

# For Demographics
missing_demographics <- demographics %>%
  mutate(across(all_of(required_demographics_fields), as.character)) %>%
  filter(if_any(all_of(required_demographics_fields), is.na)) %>%
  select(user_id, about, everything()) %>%
  pivot_longer(cols = all_of(required_demographics_fields), names_to = "Field", values_to = "Value") %>%
  filter(is.na(Value)) %>%
  mutate(Form = "GPSA Demographics")

# For Course Tracking
missing_course_tracking <- course_tracking %>%
  mutate(across(all_of(required_course_fields), as.character)) %>%
  filter(if_any(all_of(required_course_fields), is.na)) %>%
  select(user_id, about, everything()) %>%
  pivot_longer(cols = all_of(required_course_fields), names_to = "Field", values_to = "Value") %>%
  filter(is.na(Value)) %>%
  mutate(Form = "GPSA Course Tracking")

# Print the missing data for review
if (!is.null(missing_candidate_details)) {
  cat("Missing data for GPSA Candidate Details:", nrow(missing_candidate_details), "\n")
}

if (!is.null(missing_demographics)) {
  cat("Missing data for GPSA Demographics:", nrow(missing_demographics), "\n")
}

if (!is.null(missing_course_tracking)) {
  cat("Missing data for GPSA Course Tracking:", nrow(missing_course_tracking), "\n")
}

# ---------------------
# 3. CONSOLIDATE MISSING DATA
# ---------------------

# Combine all the missing data from different forms into a single dataframe
missing_data <- bind_rows(
  missing_candidate_details,
  missing_demographics,
  missing_course_tracking
)

# ---------------------
# 4. GATHER MISSING DATA INTO A CSV
# ---------------------

# Define your desired folder path
folder_path <- "/path/to/your/folder"  # Modify this to your desired folder path

# Create the full file path by combining the folder_path with the file name
file_path <- file.path(folder_path, "missing_data_report.csv")

# Write the result to the specified CSV file
write.csv(missing_data_csv, file_path, row.names = FALSE)

# Display the final dataframe for review
print(missing_data_csv)



















