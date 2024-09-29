import os
import subprocess
import argparse
import logging

# Function to get the duration of a video file using ffprobe
def get_video_duration(video_path):
    try:
        result = subprocess.run(
            [
                'ffprobe', '-v', 'error', '-select_streams', 'v:0',
                '-show_entries', 'format=duration', '-of', 'csv=p=0', video_path
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        # Convert duration from seconds to a float
        return float(result.stdout.strip())
    except Exception as e:
        logging.error(f"Error getting duration for {video_path}: {e}")
        return None

# Function to delete files using sudo
def delete_file_with_sudo(file):
    try:
        subprocess.run(['sudo', 'rm', file], check=True)
        print(f"Deleted {file}.")
        logging.info(f"Successfully deleted: {file}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to delete {file}: {e}")
        logging.error(f"Failed to delete {file}: {e}")

# Function to prompt user for bulk deletion and log the action
def prompt_for_bulk_deletion(files_to_delete, test_mode):
    if not files_to_delete:
        print("No files marked for deletion.")
        logging.info("No files were marked for deletion.")
        return
    
    print("The following files are marked for deletion:")
    for file, duration in files_to_delete:
        hours = int(duration // 3600)
        minutes = int((duration % 3600) // 60)
        seconds = int(duration % 60)
        print(f" - {file} (Duration: {hours:02}:{minutes:02}:{seconds:02})")
        logging.info(f"File marked for deletion: {file} (Duration: {hours:02}:{minutes:02}:{seconds:02})")
    
    while True:
        user_input = input("Do you want to delete all these files? (y/n): ").strip().lower()
        if user_input in ['y', 'n']:
            if user_input == 'y':
                logging.info("User chose to delete the marked files.")
                if test_mode:
                    print("Test mode: The files listed above would have been deleted.")
                    logging.info("Test mode: No files were deleted.")
                else:
                    for file, _ in files_to_delete:
                        delete_file_with_sudo(file)  # Use sudo for deletion
            else:
                print("No files were deleted.")
                logging.info("User chose not to delete the marked files.")
            break

# Main script logic
def main(folder_path, max_length, test_mode, debug_mode, log_file):
    # Set up logging
    logging.basicConfig(filename=log_file, level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
    logging.info("Script started.")
    
    files_to_delete = []  # List to keep track of files marked for deletion
    
    # Iterate over all files in the specified folder
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            # Process video files with supported extensions
            if file.lower().endswith(('.mp4', '.mkv', '.avi', '.mov', '.flv', '.m4v')):
                video_path = os.path.join(root, file)
                duration = get_video_duration(video_path)
                
                if duration is None:
                    logging.warning(f"Skipping {file} due to error retrieving duration.")
                    continue
                
                # Debug print to show file processing and duration
                if debug_mode:
                    print(f"Processing file: {file}, Duration: {duration} seconds")
                
                # If video is shorter than the maximum length, mark for deletion
                if duration < max_length:
                    files_to_delete.append((video_path, duration))
    
    # Prompt for bulk deletion
    prompt_for_bulk_deletion(files_to_delete, test_mode)

    logging.info("Script finished.")

if __name__ == "__main__":
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Delete videos shorter than a specified length.")
    parser.add_argument("folder", help="The folder containing video files to scan.")
    parser.add_argument("max_length", type=int, help="The maximum video length in seconds. Videos shorter than this will be candidates for deletion.")
    parser.add_argument("log_file", help="The path to the log file.")
    parser.add_argument("--test", action="store_true", help="Simulate the execution without actually deleting any files.")
    parser.add_argument("--debug", action="store_true", help="Enable debug mode to print processing information.")
    
    args = parser.parse_args()
    
    # Run the main function
    main(args.folder, args.max_length, args.test, args.debug, args.log_file)
