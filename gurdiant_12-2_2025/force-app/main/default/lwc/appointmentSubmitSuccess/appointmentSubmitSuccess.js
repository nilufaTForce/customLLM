import { LightningElement } from 'lwc';

export default class AppointmentSubmitSuccess extends LightningElement {

    handleHomeClick() {
        // Redirect to the home page or perform other actions as needed
        window.location.href = '/home'; // Replace with your home URL or Lightning page
    }
}