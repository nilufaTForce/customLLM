import { LightningElement, track } from 'lwc';

export default class VideoCallLinkCreator extends LightningElement {
    @track link;

    createLink() {
        fetch('https://agora-video-call-link.vercel.app/createVideoLink', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok ' + response.statusText);
            }
            return response.json();
        })
        .then(data => {
            this.link = data.link;
        })
        .catch(error => {
            console.error('Error fetching link:', error);
        });
    }
}