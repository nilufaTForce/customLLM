import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import generateToken from '@salesforce/apex/AgoraTokenController.generateToken';
import AGORA_SDK from '@salesforce/resourceUrl/AgoraSDK'; // Reference your static resource here

export default class AgoraVideoCall extends LightningElement {
    appId = 'f3769cf18ead47c3b2ac521d9471dafe'; // Replace with your Agora App ID
    channelName = 'testChannel';
    uid = Math.floor(Math.random() * 1000);
    client;
    localTracks = [];
    remoteUsers = {};
    scriptLoaded = false;

    renderedCallback() {
        if (!this.scriptLoaded) {
            this.scriptLoaded = true;
            // Load the Agora SDK script from the static resource
            loadScript(this, AGORA_SDK)
                .then(() => {
                    console.log('Agora SDK loaded successfully.');
                    // Check if AgoraRTC is available globally after loading
                    if (window.AgoraRTC) {
                        console.log('AgoraRTC is available');
                    } else {
                        console.error('AgoraRTC is not defined');
                    }
                })
                .catch((error) => {
                    console.error('Error loading Agora SDK:', error);
                });
        }
    }

    async handleJoin() {
        try {
            // Fetch token from Apex
            const token = await generateToken({ channelName: this.channelName, uid: this.uid });

            // Ensure AgoraRTC is available
            if (!window.AgoraRTC) {
                console.error('AgoraRTC is not available.');
                return;
            }

            // Initialize the Agora client
            this.client = window.AgoraRTC.createClient({ mode: 'rtc', codec: 'vp8' });

            // Join the Agora channel
            await this.client.join(this.appId, this.channelName, token, this.uid);

            // Get available devices
            const devices = await window.AgoraRTC.getDevices();
            const videoDevices = devices.filter((device) => device.kind === 'videoinput');
            const audioDevices = devices.filter((device) => device.kind === 'audioinput');

            if (audioDevices.length === 0) {
                alert('No microphone found on this device.');
                return;
            }

            const isVideoAvailable = videoDevices.length > 0;

            // Create local tracks
            if (isVideoAvailable) {
                this.localTracks = await window.AgoraRTC.createMicrophoneAndCameraTracks();
                this.localTracks[1].play('local-player');
            } else {
                alert('No camera found. Joining with audio only.');
                const microphoneTrack = await window.AgoraRTC.createMicrophoneAudioTrack();
                this.localTracks = [microphoneTrack];
                this.template.querySelector('.local-player').innerHTML = '<p>Audio-only mode: Microphone is active</p>';
            }

            // Publish local tracks
            await this.client.publish(this.localTracks);

            // Event handlers for remote users
            this.client.on('user-published', this.handleUserPublished.bind(this));
            this.client.on('user-unpublished', this.handleUserUnpublished.bind(this));

            console.log('Successfully joined the channel!');
        } catch (error) {
            console.error('Error joining the channel:', error);
            alert('Error: ' + error.message);
        }
    }

    async handleLeave() {
        try {
            console.log('Leaving channel...');
            console.log('Current client state:', this.client);
    
            // Unpublish local tracks
            if (this.localTracks.length) {
                console.log('Unpublishing local tracks...');
                this.localTracks.forEach((track) => track.close());
                await this.client.unpublish(this.localTracks);
            }
    
            // Leave the channel
            console.log('Leaving the Agora channel...');
            await this.client.leave();
            // Check if the elements exist before trying to update them
            const localPlayerContainer = this.template.querySelector('.local-player');
            const remotePlayerContainer = this.template.querySelector('.remote-player');

            if (localPlayerContainer) {
                localPlayerContainer.innerHTML = '';
            } else {
                console.error('Local player container not found');
            }

            if (remotePlayerContainer) {
                remotePlayerContainer.innerHTML = '';
            } else {
                console.error('Remote player container not found');
            }

            // Reset local tracks
            this.localTracks = [];
            // Clear player containers
            this.template.querySelector('.local-player').innerHTML = '';
            this.template.querySelector('.remote-player').innerHTML = '';
    
            // Reset remote users
            this.remoteUsers = {};
    
            console.log('Successfully left the channel!');
        } catch (error) {
            console.error('Error leaving the channel:', error);
            console.log('Error details:', error);
        }
    }
    

    async handleUserPublished(user, mediaType) {
        try {
            // Subscribe to the remote user
            await this.client.subscribe(user, mediaType);
            console.log('Subscribed to user:', user.uid);

            if (mediaType === 'video') {
                // Create a new div for the remote user's video
                const remotePlayer = document.createElement('div');
                remotePlayer.id = `player-${user.uid}`;
                remotePlayer.style.width = '400px';
                remotePlayer.style.height = '300px';
                this.template.querySelector('#remote-player').appendChild(remotePlayer);

                // Play the remote video
                user.videoTrack.play(remotePlayer.id);
            }

            if (mediaType === 'audio') {
                console.log(`User ${user.uid} has joined with audio only.`);
                const audioIndicator = document.createElement('p');
                audioIndicator.id = `audio-${user.uid}`;
                audioIndicator.textContent = `User ${user.uid} (Audio Only)`;
                this.template.querySelector('#remote-player').appendChild(audioIndicator);

                // Play the remote audio
                user.audioTrack.play();
            }
        } catch (error) {
            console.error('Error subscribing to user:', error);
        }
    }

    handleUserUnpublished(user, mediaType) {
        try {
            console.log('User unpublished:', user.uid);

            if (mediaType === 'video') {
                const remotePlayer = this.template.querySelector(`#player-${user.uid}`);
                if (remotePlayer) remotePlayer.remove();
            }

            delete this.remoteUsers[user.uid];
        } catch (error) {
            console.error('Error unsubscribing from user:', error);
        }
    }
}