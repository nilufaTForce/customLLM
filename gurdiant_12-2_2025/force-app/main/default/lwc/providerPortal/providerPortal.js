import { LightningElement ,track ,wire} from 'lwc';
import getProviderDetail from '@salesforce/apex/CustomCalendarController.getProviderDetail';
import getAppointmentsByProvider from '@salesforce/apex/CustomCalendarController.getAppointmentsByProvider';
import deleteAppointmentById from '@salesforce/apex/CustomCalendarController.deleteAppointmentById';


export default class ProviderPortal extends LightningElement {
    providerId = 'a1RWr000000XXd7MAG';
    @track provider;
    @track name = '';
    @track providerType=''; 
    @track provider = '';
    @track groupLocation = '';
    @track affiliatedGroup = '';
    @track appointmentType = '';
    @track careCat = '';
    @track timeZone= '';
    @track gender = '';
    @track lang = '';
    @track phone = '';
    @track email = '';


     error;
     @track isExpanded = true;
     @track isExpanded2 = true;

     @track appointments = [];
     handleViewAll() {
        // Navigate or load all appointments
        console.log('View All clicked');
    }

    handleCreateAppointment() {
        // Handle create new appointment action
        console.log('Create New Appointment clicked');
    }

    handleAppointmentClick(event) {
        // Handle individual appointment click
        const appointmentId = event.target.textContent;
        console.log('Appointment clicked:', appointmentId);
    }
    @wire(getAppointmentsByProvider, { providerId: '$providerId' })
    wiredAppointments({ error, data }) {
        if (data) {
            // Transform the Apex result into the desired structure
            this.appointments = data.map(appointment => ({
                id: appointment.Id,
                location: appointment.Clinic_Location__r.Name || 'Unknown Location',
                dateTime: this.formatDateTime(appointment.Appointed_Date__c, appointment.Start_Time__c),
                status: appointment.Status__c || 'Unknown',
                providerType : appointment.Resource_Type__r.Name || 'Unknown Type',
                showDropdown: false
            }));
        } else if (error) {
            console.error('Error fetching appointments:', error);
        }
    }

    formatDateTime(date, time) {
        if (!date) {
            return 'Invalid Date';
        }
        // Format date and time to "MM/DD/YYYY, hh:mmAM/PM"
        const appointmentDate = new Date(date);
        const options = { month: '2-digit', day: '2-digit', year: 'numeric' };
        let formattedDate = appointmentDate.toLocaleDateString('en-US', options);

        if (time) {
            const timeDate = new Date(`${date}T${time}`);
            const timeOptions = { hour: 'numeric', minute: '2-digit', hour12: true };
            const formattedTime = timeDate.toLocaleTimeString('en-US', timeOptions);
            return `${formattedDate}`;
        }
        return `${formattedDate}`;
    }

    getCardClass(status) {
        // Add a special CSS class if the status is "Running"
        return status === 'Running' ? 'highlight' : '';
    }

    handleNavigate(event) {
        // Handle navigation logic here
        event.preventDefault();
        console.log('Navigate to appointment details');
    }

    handleAction(event) {
        // Handle dropdown actions here
        console.log('Action clicked');
    }
   
      @wire(getProviderDetail, { providerId: '$providerId'})
      wiredProvider({ error, data }) {
          if (data) {
              this.provider = data;
              this.error = undefined;  
            //  this.name = this.provider.Name;// Reset error if data is received









              this.name = data.Name;
              this.providerType = data.Resource_Type__r.Name;
              this.groupLocation = data.Clinic_Location__r.Name;
              this.affiliatedGroup = data.Clinic_Location__r?.Provider_Company__r.Name || '';
              this.appointmentType = data.Appointment_Type__r.Name;
              this.careCat = data.Resource_Type__r?.Resource_Category__r.Name || '';
              this.timeZone = data.Time_Zone__c;
              this.email = data.Email__c;










          } else if (error) {
              this.provider = undefined;  // Reset provider if error occurs
              this.error = 'An error occurred while retrieving provider details: ' + error.body.message;
          }
      }
      connectedCallback(){
        document.addEventListener('click', this.handleClickOutside);
      }
      toggleSection() {
        this.isExpanded = !this.isExpanded;
        // console.log("hmm" + this.isExpanded);
    }
    toggleSection2() {
        this.isExpanded2 = !this.isExpanded2;
        // console.log("hmm" + this.isExpanded);
    }
      groupLocation = 'New York';
    
      // State to toggle between view and edit mode
      isEditing = false;
  
      // Handles the click event on the pencil icon to toggle edit mode
      handleEditClick() {
          this.isEditing = true;
      }
  
      // Handles changes to the value in the input field
      handleValueChange(event) {
          this.groupLocation = event.target.value;
      }
      disconnectedCallback() {
        document.removeEventListener('click', this.handleClickOutside);
    }


      handleToggleDropdown(event) {
        event.stopPropagation(); // Prevent the click event from propagating to the document
        const appointmentId = event.target.dataset.id; // Access the id from data-id
        const appointment = this.appointments.find(app => app.id === appointmentId);
        appointment.showDropdown = !appointment.showDropdown;
    }

    // Handle clicks outside the dropdown
    handleClickOutside = (event) => {
        // Check if the click is outside the dropdown and button
        const dropdowns = this.template.querySelectorAll('.dropdown-options');
        const buttons = this.template.querySelectorAll('.slds-button-icon');
        
        dropdowns.forEach(dropdown => {
            if (dropdown && !dropdown.contains(event.target) && !Array.from(buttons).some(button => button.contains(event.target))) {
                this.appointments.forEach(appointment => {
                    appointment.showDropdown = false; // Close dropdown for all appointments
                });
            }
        });
    }

    // Edit action
    handleEdit(event) {
        const appointmentId = event.target.dataset.id; // Access the id from data-id
        console.log(`Edit action for appointment with ID: ${appointmentId}`);
        // Add your edit logic here, like navigating to an edit page or opening a modal
    }

    // Delete action
    handleDelete(event) {
        const appointmentId = event.target.dataset.id; // Access the id from data-id
        console.log('hhhhhhhhhhhhhhhhhhh '+appointmentId);
        this.handleDeletee(appointmentId);
        // const appointmentIndex = this.appointments.findIndex(app => app.id === appointmentId);
        // if (appointmentIndex > -1) {
        //     this.appointments.splice(appointmentIndex, 1);  // Remove the appointment from the list
        //     console.log(`Deleted appointment with ID: ${appointmentId}`);
        // }

    }
    handleDeletee(appointmentId) {
    
        console.log('kkkk ',appointmentId);
        deleteAppointmentById({ appointmentId })
            .then(() => {
                console.log('uuu ');

                //console.log(`Appointment with ID ${appointmentId} deleted successfully.`);

                this.appointments = this.appointments.filter(appointment => appointment.id !== appointmentId);
                window.location.reload();
                // Add logic to refresh the list or show success message
            })
            .catch((error) => {
                console.error('Error deleting appointment:', error);
                window.location.reload();
                // Add logic to handle errors and show user-friendly messages
            });
    }

    // View All action
    handleViewAll() {
        console.log('View All clicked');
        // Implement your View All logic, like navigating to a detailed page or expanding the list
    }





}