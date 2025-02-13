// Define the function to start screen recording
let mediaRecorder;
let chunks = [];

function startScreenRecording() {
    // Request permission to capture the screen
    navigator.mediaDevices.getDisplayMedia({ video: true })
        .then((stream) => {
            mediaRecorder = new MediaRecorder(stream);
            mediaRecorder.start();
            console.log("Recording started...");

            // Collect the video data as it records
            mediaRecorder.ondataavailable = function(event) {
                chunks.push(event.data);
            };

            // When the recording stops, process and download the video
            mediaRecorder.onstop = function() {
                const blob = new Blob(chunks, { type: "video/webm" });
                const videoUrl = URL.createObjectURL(blob);
                downloadVideo(videoUrl);
            };
        })
        .catch((err) => {
            console.error("Error: " + err);
        });
}

// Function to download the video once recording is stopped
function downloadVideo(url) {
    const a = document.createElement("a");
    a.href = url;
    a.download = "screen-recording.webm";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}
