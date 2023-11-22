# Load necessary libraries
library(neon)
library(dplyr)
library(tidyr)

# ---------------------
# Date Configuration
# ---------------------

# For the current date:
# start_date <- format(Sys.Date(), "%d/%m/%Y")
# end_date <- start_date

# For a manually set date:
start_date <- "01/01/2021"
end_date <- "24/08/2023"

# Define the group
group_name <- "SWCC Candidates"

# Function to pull data from Smartabase with logging
pull_data_with_logging <- function(form_name) {
  cat("Attempting to pull data for form:", form_name, "\n")
  tryCatch({
    data <- pull_smartabase(
      form = form_name,
      filter_user_key = "group",
      filter_user_value = group_name,
      start_date = start_date,
      end_date = end_date
    )
    cat("Successfully pulled data for form:", form_name, "\n")
    return(data)
  }, error = function(e) {
    cat("Failed to pull data for form", form_name, ":", e$message, "\n")
    return(NULL)
  })
}

# Pull the updated data for users identified as having missing data
updated_candidate_details <- pull_data_with_logging("GPSA Candidate Details")
updated_demographics <- pull_data_with_logging("GPSA Demographics")
updated_course_tracking <- pull_data_with_logging("GPSA Course Tracking")

# Prepare data for GPSA Admin Details form
admin_details_push_data <- updated_candidate_details %>%
  left_join(updated_demographics, by = "user_id") %>%
  left_join(updated_course_tracking, by = "user_id") %>%
  select("user_id", "First Name [Update]", "Last Name [Update]", "Date of Birth [Update]", 
         "DOD ID Number [Change]", "USAF Status [Update]", "Race", "Ethnicity", 
         "4 Digit Course Number", "Entering Date") %>%
  rename(
    `First Name` = `First Name [Update]`,
    `Last Name` = `Last Name [Update]`,
    DOB = `Date of Birth [Update]`,
    `DOD ID Number` = `DOD ID Number [Change]`,
    `USAF Status` = `USAF Status [Update]`,
    `Entry Cohort` = `4 Digit Course Number`,
    `Entry FY` = `Entering Date`
  )


# Prepare data for GPSA AFSC Tracking form
afsc_tracking_push_data <- updated_candidate_details %>%
  select("user_id", "USAF Status [Update]", "Rank [Update]") %>%
  rename(
    `USAF Status` = `USAF Status [Update]`,
    Rank = `Rank [Update]`
  )

# ---------------------
# Date Configuration for Data Push
# ---------------------

desired_start_date <- "24/08/2023"
desired_end_date <- "24/08/2023"
desired_start_time <- "09:00 AM"
desired_end_time <- "10:00 AM"

# Add start_time and end_time columns to the dataframe
admin_details_push_data$start_time <- desired_start_time
admin_details_push_data$end_time <- desired_end_time


# ---------------------
# Push Updates to Smartabase
# ---------------------

# Define your entered_by_user_id
# Set the entered_by_user_id (replace with actual ID)
ENTERED_BY_USER_ID <- ######

# Define the push function with logging
push_data_with_logging <- function(form_name, data_to_push, type = "event", start_date_push = NULL, end_date_push = NULL) {
  cat("Attempting to push data to form:", form_name, "\n")
  
  # If start_date_push or end_date_push are provided, we'll add them to the data frame
  if(!is.null(start_date_push)) {
    data_to_push$start_date <- start_date_push
  }
  if(!is.null(end_date_push)) {
    data_to_push$end_date <- end_date_push
  }
  
  tryCatch({
    push_smartabase(
      df = data_to_push,
      form = form_name,
      type = type,
      entered_by_user_id = ENTERED_BY_USER_ID  # Add this line
    )
    cat("Successfully pushed data to form:", form_name, "\n")
  }, error = function(e) {
    cat("Failed to push data to form", form_name, ":", e$message, "\n")
  })
}

# Desired start and end dates
desired_start_date <- format(Sys.Date(), "%d/%m/%Y")
desired_end_date <- desired_start_date

# Push data to forms
push_data_with_logging(
  form_name        = "GPSA Admin Details",
  data_to_push     = admin_details_push_data,
  type             = "profile",
  start_date_push  = desired_start_date,
  end_date_push    = desired_end_date
)

push_data_with_logging(
  form_name        = "GPSA AFSC Tracking",
  data_to_push     = afsc_tracking_push_data,
  start_date_push  = desired_start_date,
  end_date_push    = desired_end_date
)

# Pull recent data
recent_data <- pull_smartabase(
  form = "GPSA Admin Details",
  start_date = format(Sys.Date() - 1, "%d/%m/%Y"),
  end_date = format(Sys.Date(), "%d/%m/%Y")
)

# View the recent data
print(recent_data)







