import { LightningElement } from 'lwc';
import SCREEN_RECORDING_JS from '@salesforce/resourceUrl/ScreenRecordingJS'; // Import static resource for screen recording logic

export default class ScreenRecordButton extends LightningElement {

    // This method runs when the button is clicked
    startRecording() {
        // Dynamically load the MediaRecorder script from static resource
        this.loadScript()
            .then(() => {
                // Once the script is loaded, call the startRecording function defined inside the script
                this.initializeRecording();
            })
            .catch((error) => {
                console.error("Error loading script:", error);
            });
    }

    // Dynamically load the static resource JavaScript file
    loadScript() {
        return new Promise((resolve, reject) => {
            // Check if the script has already been loaded (in case of a re-trigger)
            if (window.MediaRecorder && typeof startScreenRecording === 'function') {
                resolve();
                return;
            }

            // Otherwise, dynamically load the script
            const script = document.createElement('script');
            script.src = SCREEN_RECORDING_JS; // Static resource URL
            script.onload = () => {
                console.log('Screen recording script loaded successfully.');
                resolve(); // Resolve when the script is successfully loaded
            };
            script.onerror = (error) => {
                console.error('Error loading the screen recording script:', error);
                reject(error); // Reject if there is an error loading the script
            };
            document.body.appendChild(script); // Append the script to the body
        });
    }

    // Initialize the screen recording after the script is loaded
    initializeRecording() {
        if (typeof startScreenRecording === 'function') {
            console.log('Starting screen recording...');
            startScreenRecording(); // Call the function defined in the static resource
        } else {
            console.error('startScreenRecording function is still not available.');
        }
    }
}