import { api, LightningElement } from 'lwc';
import getRecordTypeNameById from '@salesforce/apex/CustomCalendarController.getRecordTypeNameById';
export default class ModalView extends LightningElement {
    @api appointmentDetails;

    locationFlag = true;
    // clinicLocation = 'https://www.google.com/maps?q=';
    clinicLocation = '/';
    clinic = true;
    providerAddress = '/';
    provider =true;
    patientName = '/'
    patient=true;
    AppointmentType = '/';
    Appointment=true;
    ProviderType = '/'; 
    ProviderT=true;
    careCategory = '/'; 
    care=true;
    recordType = '/'; 
    record=true;
    recordTypeName = '';
    providorID='';
    docnName=true;
    docId  = '/'; 
    groupLocationID= '/'; 
    groupLocation =true;
   

    // Method to format the date
    get formattedDate() {
        const date = new Date(this.appointmentDetails.date);
        
        const day = date.getDate();
        const month = date.toLocaleString('default', { month: 'long' });  // Get full month name
        const year = date.getFullYear();

        return `${day} ${month}, ${year}`;
    }
    get formattedDuration() {
        const durationInHours = parseFloat(this.appointmentDetails.duration);  // Assuming duration is a string like "0.5 hour"
        
        // Convert hours to minutes
        const durationInMinutes = durationInHours * 60;

        return `${durationInMinutes} minutes`;  // Return the formatted string
    }


    connectedCallback(){
        if(this.appointmentDetails.patientName =='N/A'){
            this.patient = false;
        }
        if(this.appointmentDetails.locationName =='N/A'){
            this.clinic = false;
        }
        if(this.appointmentDetails.locationID =='N/A'){
            this.groupLocation =false;
          
        }

       
        if (this.appointmentDetails.locationName == 'N/A') {
            this.locationFlag = false;
        }
        if(this.appointmentDetails.doctorName =='N/A'){
            this.docnName = false;
        }
        if(this.appointmentDetails.providerName =='N/A'){
            this.provider = false;
        }
        if(this.appointmentDetails.AppointmentType =='N/A'){
            this.Appointment = false;
        }

       
        if (this.appointmentDetails.ProviderType == 'N/A') {
            this.ProviderT= false;
        }
        if(this.appointmentDetails.careCategory =='N/A'){
            this.care = false;
        }
        if(this.appointmentDetails.recordType =='N/A'){
            this.record = false;
        }

        // console.log('this.appointmentDetails.location', this.appointmentDetails.location);
        this.patientName += this.appointmentDetails.patientId;
     
        this.clinicLocation += this.appointmentDetails.location;
        this.providerAddress += this.appointmentDetails.clinicName;
        this.AppointmentType += this.appointmentDetails.AppointmentType;
     
        this.providerI += this.appointmentDetails.ProviderType;
        this.ProviderType += this.appointmentDetails.ProviderType;
        this.careCategory += this.appointmentDetails.careCategory;
        this.recordType += this.appointmentDetails.recordType;
        this.docId += this.appointmentDetails.doctorNameID;
        this.groupLocationID += this.appointmentDetails.locationID;
      
      
        this.getRecordTypeName();
    }
    getRecordTypeName() {
        getRecordTypeNameById({ recordTypeId: this.appointmentDetails.recordType })
            .then(result => {
                // Store the result in the recordTypeName property
                this.recordTypeName = result;
            })
            .catch(error => {
                // Handle any errors
                console.error("Error retrieving Record Type Name: ", error);
                this.recordTypeName = 'Error retrieving name';
            });
    }


}