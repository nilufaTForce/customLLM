import { LightningElement, api, track ,wire} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getAvailableSlots from '@salesforce/apex/CustomCalendarController.getAvailableAppointmentSlots';

import retrieveClosestClinicLocationId from '@salesforce/apex/DistanceService.getClosestClinicLocationId';
import receiveAllAffiliatedGrps from '@salesforce/apex/CustomCalendarController.getAllAffiliatedGrps';
import receiveAllCareCategories from '@salesforce/apex/CustomCalendarController.getAllCareCategories';
import receiveCareCategoriesOfClinic from '@salesforce/apex/CustomCalendarController.getCareCatOfTheClinic';  
import receiveGrpLocationsOfACareCat from '@salesforce/apex/CustomCalendarController.getAllLocationOfSameCareCat';                                

import receiveAllAppTypes from '@salesforce/apex/CustomCalendarController.getAllAppTypes';
import receiveAllGrpLocations from '@salesforce/apex/CustomCalendarController.getAllGrpLocations';
import receiveAllProviderTypes from '@salesforce/apex/CustomCalendarController.getAllProviderTypes';

import receiveAllProviders from '@salesforce/apex/CustomCalendarController.getAllProviders';
import sendAppointment from '@salesforce/apex/CustomCalendarController.createAppointment';
import receivePatientRecordTypeID from '@salesforce/apex/CustomCalendarController.getPatientRecordTypeID';

import getAppointments from '@salesforce/apex/CustomCalendarController.getAvailableAppointmentSlots';
import getProvidersTimeFiltered from '@salesforce/apex/CustomCalendarController.getAvailableProviders';
import receiveAllAvailabilities from '@salesforce/apex/CustomCalendarController.getAllAvailabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// getAllAvailabilities




export default class NewAppointment extends LightningElement {
 

    @track selectedRecordTypeValue = 'Appointment'; // Default value
    @track isAppointment = true; // Controls the rendering of Appointment-specific fields
    @track isUnavailable = false; // Controls the rendering of Unavailable-specific fields
    @track groupAddress = ''; // Default value
    @track groupAddressU = '';
    @track startTimeOptions = [];
    @track endTimeOptions = [];

 @track value = '';
    careCategoryList = [];

    @api fromCalendar = false;
  
    @api newAppointmentModal;
    @api newRecordTypeModal;
    @track calender = false;
    @track form = true
    @track selectedTimeDropdown = "11:30 AM";
    @track selectedEndTimeDropdown = "12:00 PM";
    @track selectedCareCatU = '';
    @track selectedProviderU = '';
    @track endTimeU='';
    @track startTimeU = '';
    @track startTime = '';
    @track selectedDateU = '';
    @track selectedGroupU;
    @track selectedGrpLocationU;
    @track selectedProviderTypeU = '';
    @track selectedProvider;
    @track selectedDurationU;
    @track showClinicLocation = true;
    @track address;
    @track  providerComp= "a1MWr000001PsO1MAK";




    roomTypeOptions = [
        { label: 'Gen One Room', value: 'Gen One Room' },
        { label: 'Gen One Virtual', value: 'Gen One Virtual' }
    ];

    telehealthOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    selectedDuration = '00:00';
    spinner = false;
    dat = '';
    ClinickNotFoundMsg = '';
    closestClinicId = null;
    activeTab = '2';
    marginStyle = '';
    accountID = '';
    affilitedGrpID;

    isPatientRequired = true;
    isCareCatRequired = true;
    isAppTypeRequired = true;
    isTelehealthRequired = true;
    isDateRequired = true;
    isStartTimeRequired = true;
    isGroupRequired = true;
    isGrpLocationRequired = true;
    isProviderTypeRequired = true;
    isProviderRequired = true;
    isEventTypeUnavailable = false;
    isGroupAddressRequired = true;

    filterPatients = {}
    allCareCategories = [];
    allAppTypes = [];
    allGrpLocations = [];
    allGroups = [];
    allProviderTypes = [];
    allProviders = [];
    allAvailabilites = [];

    appTypesOptions = [];
    grpOptions = [];
    grpLocationOps = [];
    providerTypeOptions = [];
    @track providerOptions = [];
    grpOptionsUnavailable = [];
    grpLocationOpsUnavailable = [];
    providerTypeOptionsUnavailable = [];
    @track providerOptionsUnavailable = [];
    isTelehealth = false;
    telehealthDefault = 'No';
    @track isStartTimeDisabled = true;
    @track isStartTimeInvalid = false;
    @track isTelehealthYes = false;
    defaultRoomTypeOptions = [
        { label: 'Gen One Room', value: 'Gen One Room' },
        { label: 'Gen Two Room', value: 'Gen Two Room' }
    ];
    @track roomTypeOptions = this.defaultRoomTypeOptions;
    @track selectedRoomType = this.defaultRoomTypeOptions[0].value;



    // Placeholder option for Telehealth "Yes"
    placeholderRoomType = [
        { label: '--', value: '--' }
    ];

    @track selectedCareCatID = '';
    @track selectedAppTypeID = '';
    @track selectedgrpLocationID = '';
    @track selectedGrpID = '';
    @track selectedProviderTypeID = '';
    @track isEndTimeDisabled = true;
    @track selectedNoteU = '';

    duration = '';
    endTime = null;

    appointment = {
        event_Type: null,
        Patient_Account__c: null,
        Provider_Company__c: null,
        Resource_Category__c: null,
        Appointment_Type__c: null,
        Appointed_Date__c: null,
        Clinic_Location__c: null,
        Description__c: null,
        Telehealth__c: 'No',
        Clinic_Resource__c: null,
        Resource_Type__c: null,
        Room_Type__c: 'One Gen Room',
        Start_Time__c: null,
        End_Time__c: null,
        Time_Zone__c: null
    }

    errorMessage = null;
    timeErrorMessage = null

    newAppModal = false;
    selectedRecordTypeValue = 'Appointment';
    locationRadiusOptions = [
        { label: '5 KM', value: '5 KM' },
        { label: '10 KM', value: '10 KM' },
        { label: '15 KM', value: '15 KM' },
        { label: '30 KM', value: '30 KM' },
        { label: '50 KM', value: '50 KM' }
    ];
    _recordId;
    isInitialized = false;
   // Getter for recordId
   get recordId() {
       return this._recordId;
   }

   // Setter for recordId
   @api set recordId(value) {
       this._recordId = value || 'null';
       console.log('Record ID set to:', value);
       console.log('Record ID set to:',  this._recordId);
       if (!this.isInitialized) {
           this.initializeComponent();
       }
       // Perform additional logic if required when recordId is set
   }

    selectedLocationRadius = null;
    handleLocationRadiusChange(event) {
        this.selectedLocationRadius = event.detail.value;
        // console.log('Selected Location Radius:', this.selectedLocationRadius);
    }
    handleNotesChangeU(event){
          this.selectedNoteU = event.target.value;
    }
    handleEndTimeChange(event) {
        this.endTime = event.target.value; // Store the end time value
        // console.log('End Time:', this.endTime);
        // console.log('start Time:', this.startTime);

        if (this.startTime && this.endTime) {
            // If both values exist, call the calculateDuration function
            this.calculateDurationInMinutes(this.startTime, this.endTime);
        }
    }

    // Assuming you have the necessary properties defined in your component class:
    @track selectedDurationU; // Track this variable so it automatically updates the UI

    calculateDurationInMinutes(startTime, endTime) {
        // console.log('Start Time:', startTime);
        // console.log('End Time:', endTime);


        const startDate = new Date(`1970-01-01T${startTime}Z`);
        const endDate = new Date(`1970-01-01T${endTime}Z`);

        // console.log('Start Date:', startDate);
        // console.log('End Date:', endDate);

        // Calculate the difference in milliseconds
        const durationMilliseconds = endDate - startDate;
        // console.log('Duration in milliseconds:', durationMilliseconds);

        // Check if the duration is negative (i.e., end time is earlier than start time)
        if (durationMilliseconds < 0) {
            // console.log("End time can't be earlier than start time.");
            this.selectedDurationU = 'Invalid duration';
            return;
        }

        // Convert milliseconds to minutes
        const durationMinutes = Math.floor(durationMilliseconds / (1000 * 60));
        // console.log(`Duration: ${durationMinutes} minutes`);

        this.durationInMinutesU = durationMinutes;
        this.selectedDurationU = `${durationMinutes} minutes`;
    }

    get appTodayDate() {
        const currentDate = new Date();
        const year = currentDate.getFullYear();
        const month = String(currentDate.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
        const day = String(currentDate.getDate()).padStart(2, '0');

        return `${year}-${month}-${day}`;
    }

    // handleGrouplocation(event) {
    //     console.log("im grp loc" + event.detail.value);
    //     console.log("im grp loc" + event.detail.value.Id);
    // }

    // handleGroupId(event) {
    //     console.log("handleGroupId-->" + event.detail.value);
    //     this.affilitedGrpID = event.detail.value.Id;
    //     this.fetchGroupLocations(event.detail.value);
    // }


    radioRecordOptions = [
        { label: 'Appointment', value: 'Appointment' },
        { label: 'Unavailable', value: 'Unavailable' }
    ];

    @track isExpanded = true;
    @track isExpandedSection2 = true;

    toggleSection() {
        this.isExpanded = !this.isExpanded;
        // console.log("hmm" + this.isExpanded);
    }
    toggleSection2() {
        this.isExpandedSection2 = !this.isExpandedSection2;
    }
    handleOpenNewModal(e) {
        this.recordTypeModal = true;
        this.newAppModal = false;
    }

    handleRadioRecordChange(event) {
        this.selectedRecordTypeValue = event.detail.value;
        console.log(this.selectedRecordTypeValue);
        this.selectedCareCatID='';
        this.selectedAppTypeID='';
        this.selectedDuration='';
        this.selectedGrpID='';
        this.selectedgrpLocationID='';
        this.groupAddress='';
        this.selectedProviderTypeID='';
        this.selectedProvider='';
        this.selectedCareCatU='';
        this.startTime='';
        this.startTimeU='';
        this.endTime='';
        //this.endTimeU='';
       
        this.selectedDurationU=null;
        this.selectedGroupU='';
        this.selectedGrpLocationU='';
        this.groupAddressU='';
        this.selectedProviderTypeU='';
        this.selectedProviderU='';
      
        this.isStartTimeDisabled=true;
        this.isEndTimeDisabled=true;







        // Determine which section to display based on the selected event type
        if (this.selectedRecordTypeValue === 'Appointment') {
            this.isAppointment = true;
            this.isUnavailable = false;
        } else if (this.selectedRecordTypeValue === 'Unavailable') {
            this.isAppointment = false;
            this.isUnavailable = true;
        }
        let result = [
            '12:00 AM', '12:15 AM', '12:30 AM', '12:45 AM',
            '01:00 AM', '01:15 AM', '01:30 AM', '01:45 AM',
            '02:00 AM', '02:15 AM', '02:30 AM', '02:45 AM',
            '03:00 AM', '03:15 AM', '03:30 AM', '03:45 AM',
            '04:00 AM', '04:15 AM', '04:30 AM', '04:45 AM',
            '05:00 AM', '05:15 AM', '05:30 AM', '05:45 AM',
            '06:00 AM', '06:15 AM', '06:30 AM', '06:45 AM',
            '07:00 AM', '07:15 AM', '07:30 AM', '07:45 AM',
            '08:00 AM', '08:15 AM', '08:30 AM', '08:45 AM',
            '09:00 AM', '09:15 AM', '09:30 AM', '09:45 AM',
            '10:00 AM', '10:15 AM', '10:30 AM', '10:45 AM',
            '11:00 AM', '11:15 AM', '11:30 AM', '11:45 AM',
            '12:00 PM', '12:15 PM', '12:30 PM', '12:45 PM',
            '01:00 PM', '01:15 PM', '01:30 PM', '01:45 PM',
            '02:00 PM', '02:15 PM', '02:30 PM', '02:45 PM',
            '03:00 PM', '03:15 PM', '03:30 PM', '03:45 PM',
            '04:00 PM', '04:15 PM', '04:30 PM', '04:45 PM',
            '05:00 PM', '05:15 PM', '05:30 PM', '05:45 PM',
            '06:00 PM', '06:15 PM', '06:30 PM', '06:45 PM',
            '07:00 PM', '07:15 PM', '07:30 PM', '07:45 PM',
            '08:00 PM', '08:15 PM', '08:30 PM', '08:45 PM',
            '09:00 PM', '09:15 PM', '09:30 PM', '09:45 PM',
            '10:00 PM', '10:15 PM', '10:30 PM', '10:45 PM',
            '11:00 PM', '11:15 PM', '11:30 PM', '11:45 PM'
        ];

        this.startTimeOptions = result.map(item => ({
            label: item, // The display text
            value: item  // The actual value used in selection
        }));
    }

    handleproviderCompany(event) {
        // console.log("uuuu");


        // console.log("hmm"+JSON.stringify(this.filter.criteria[0].value));
        // console.log("hmm"+this.providerCompanyValue);
        this.providerCompanyValue = event.detail.value;
        // console.log(typeof this.providerCompanyValue);
        // this.filter.criteria[0].value = "";
        // console.log(JSON.stringify(this.filter.criteria[0].value));
        // console.log("yyy"+event.detail.value);
        // console.log("i m ggg" + this.providerCompanyValue[0]);

        this.filter = {
            criteria: [
                {
                    fieldPath: 'Provider_Company__c',
                    operator: 'eq',
                    value: this.providerCompanyValue[0] || "" // Safeguard with empty string in case value is undefined
                }
            ]
        };
    }
    // handle(){
    //     console.log("clicked");
    // }

    // connectedCallback() {

    //     // this.recordTypeModal = true;
    //     // console.log("kkkkkkkkkk"+this.recordTypeModal);
    //     this.sendStartTrigger();

    //     console.log("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkllllllllllllllllll");
    //     if (!this.fromCalendar) {
    //         this.loadMarginStyle();

    //     }
    //     // this.close();
    // }

    @track weeks = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    @track clinicName = '';  // To store the clinic name
    @track clinicName1 = false;
    @track ClinickNotFoundMsg = '';  // To store a message when no clinic is found
    @track availableSlots;

    @track days = []
    selectedMonth = '';
    selectedYear = '';
    selectedDay = '';
    selectedDate = '';
    clickedDay = '';
    @track clickedFullDate = 'Select a Date';
    @track availableTimes = [];
    @track timeOptions = [];
    @track selectedTime = '';
    @track isStartDateDisabled = true;
    @track isStartDateDisabledU = true;
    thisDay;

    @track dateTimeMap = new Map([
        // ['2024-10-30', ['12:15 PM', '1:15 PM', '2:30 PM']],
        // ['2024-10-29', ['12:15 PM', '1:15 PM', '2:30 PM']],
        // ['2024-11-1', ['9:00 AM', '12:45 PM']],
        // ['2024-11-2', ['8:30 AM', '2:15 PM']],
        // ['2024-11-3', ['1:00 PM', '4:30 PM']],
        // ['2024-11-4', ['10:30 AM', '5:00 PM']],
        // ['2024-11-5', ['9:15 AM', '2:45 PM', '4:00 PM']],
        // ['2024-11-6', ['11:00 AM', '1:30 PM']],
        // ['2024-11-7', ['10:45 AM', '3:15 PM']],
        // ['2024-11-8', ['8:30 AM', '11:15 AM', '5:00 PM']],
        // ['2024-11-9', ['7:00 AM', '12:30 PM', '6:15 PM']],
        // ['2024-11-24', ['7:00 AM', '12:30 PM', '6:15 PM']],
        // ['2024-11-14', ['7:00 AM', '12:30 PM', '6:15 PM']],
        // ['2024-11-27', ['7:00 AM', '12:30 PM', '6:15 PM']]
    ]);
    @track tempTimeOptions = [];
    @track catagorieOption;
    @track appointmentTypeOptions;
    async fetchAllAvailabilites() {
        await receiveAllAvailabilities({ rand: Math.random() }).then(results => {
            // console.log(JSON.stringify(results));

            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Clinic_Resource__c, value: element.Id });
                }

                this.allAvailabilites = results;
                // console.log('ava res '+JSON.stringify(results));
            } else {
                tempArr.push({ label: 'Unavailable', value: 'id' });
            }
            // this.providerOptions = tempArr;

        }).catch(error => {
            console.error('Error:', error);
        });
    }
    connectedCallback() {
        console.log('Component initialized in connectedCallback');
        this.getPatientRecordTypeID();
        this.fetchAllCareCategories();
        this.fetchAllAppTypes();
        this.fetchAllAffiliatedGroups();
        this.fetchAllGrpLocations();
        this.fetchAllProviderTypes();
        this.fetchAllProviders();

        // this.fetchAllAvailabilites();
        


        let dateeTimeMap = new Map();
          if( this.selectedRecordTypeValue == 'Unavailable'){

          


          }else{

            let result = [
                '12:00 AM', '12:15 AM', '12:30 AM', '12:45 AM',
                '01:00 AM', '01:15 AM', '01:30 AM', '01:45 AM',
                '02:00 AM', '02:15 AM', '02:30 AM', '02:45 AM',
                '03:00 AM', '03:15 AM', '03:30 AM', '03:45 AM',
                '04:00 AM', '04:15 AM', '04:30 AM', '04:45 AM',
                '05:00 AM', '05:15 AM', '05:30 AM', '05:45 AM',
                '06:00 AM', '06:15 AM', '06:30 AM', '06:45 AM',
                '07:00 AM', '07:15 AM', '07:30 AM', '07:45 AM',
                '08:00 AM', '08:15 AM', '08:30 AM', '08:45 AM',
                '09:00 AM', '09:15 AM', '09:30 AM', '09:45 AM',
                '10:00 AM', '10:15 AM', '10:30 AM', '10:45 AM',
                '11:00 AM', '11:15 AM', '11:30 AM', '11:45 AM',
                '12:00 PM', '12:15 PM', '12:30 PM', '12:45 PM',
                '01:00 PM', '01:15 PM', '01:30 PM', '01:45 PM',
                '02:00 PM', '02:15 PM', '02:30 PM', '02:45 PM',
                '03:00 PM', '03:15 PM', '03:30 PM', '03:45 PM',
                '04:00 PM', '04:15 PM', '04:30 PM', '04:45 PM',
                '05:00 PM', '05:15 PM', '05:30 PM', '05:45 PM',
                '06:00 PM', '06:15 PM', '06:30 PM', '06:45 PM',
                '07:00 PM', '07:15 PM', '07:30 PM', '07:45 PM',
                '08:00 PM', '08:15 PM', '08:30 PM', '08:45 PM',
                '09:00 PM', '09:15 PM', '09:30 PM', '09:45 PM',
                '10:00 PM', '10:15 PM', '10:30 PM', '10:45 PM',
                '11:00 PM', '11:15 PM', '11:30 PM', '11:45 PM'
            ];
    
            this.startTimeOptions = result.map(item => ({
                label: item, // The display text
                value: item  // The actual value used in selection
            }));

          }

     


        // Check if recordId is already set; initialize if not already done
        console.log(this._recordId);
        if (this._recordId && !this.isInitialized) {
            this.initializeComponent();
        }
    }
    initializeComponent() {
       
      
       
        if(this._recordId!='null'){
        this.accountID = this._recordId;
        this.appointment.Patient_Account__c =   this.accountID;
        this.isRecordIdexist =true;}
       
     else{
            console.warn('Record ID is not yet set. Initialization skipped.');

        
            this.accountID = '';
        }
        this.isInitialized = true;

     
   
    }


    // connectedCallback() {

    //     this.getPatientRecordTypeID();
    //     this.fetchAllCareCategories();
    //     this.fetchAllAppTypes();
    //     this.fetchAllAffiliatedGroups();
    //     this.fetchAllGrpLocations();
    //     this.fetchAllProviderTypes();
    //     this.fetchAllProviders();

    //     // this.fetchAllAvailabilites();
        


    //     let dateeTimeMap = new Map();
    //       if( this.selectedRecordTypeValue == 'Unavailable'){

    //         // console.log('hiiiiii');
    //         // getAppointments({
    //         //     providerTypeID: this.selectedProviderTypeID,
    //         //     appDuration: this.selectedDuration,
    //         //     locationID: this.selectedgrpLocationID,
    //         //     careCategoryID: this.selectedCareCatID,
    //         //     appointmentDate: this.appointment.Appointed_Date__c,
    //         //     doc: this.selectedProvider
    //         // }).then(result => {
    //         //     // console.log('i m miss result ' + result);
    //         //     // this.startTimeOptions = result.map(item => ({
    //         //     //     label: item, // The display text
    //         //     //     value: item  // The actual value used in selection
    //         //     // }));
    //         //     const currentDate = new Date();
    //         //     const currentTime = currentDate.getHours() * 60 + currentDate.getMinutes();

    //         //     this.startTimeOptions = result
    //         //         .filter(item => {
    //         //             // Convert each time slot to total minutes
    //         //             const [hours, minutes] = item.split(':').map(Number);
    //         //             const itemTimeInMinutes = hours * 60 + minutes;

    //         //             // If the appointment date is today, filter out past times
    //         //             if (this.appointment.Appointed_Date__c === currentDate.toISOString().split('T')[0]) {
    //         //                 return itemTimeInMinutes >= currentTime; // Keep future times
    //         //             }

    //         //             // Otherwise, include all times for future dates
    //         //             return true;
    //         //         })
    //         //         .map(item => {
    //         //             // Convert 24-hour format to 12-hour format
    //         //             let [hours, minutes] = item.split(':').map(Number);
    //         //             let period = hours >= 12 ? 'PM' : 'AM'; // Determine AM/PM
    //         //             hours = hours % 12 || 12; // Convert to 12-hour format (0 becomes 12)
    //         //             let label = `${hours}:${minutes.toString().padStart(2, '0')} ${period}`; // Format the label

    //         //             return {
    //         //                 label: label, // Display text in 12-hour format
    //         //                 value: item   // Original value in 24-hour format
    //         //             };
    //         //         });





    //         // })


    //       }else{

    //         let result = [
    //             '12:00 AM', '12:15 AM', '12:30 AM', '12:45 AM',
    //             '01:00 AM', '01:15 AM', '01:30 AM', '01:45 AM',
    //             '02:00 AM', '02:15 AM', '02:30 AM', '02:45 AM',
    //             '03:00 AM', '03:15 AM', '03:30 AM', '03:45 AM',
    //             '04:00 AM', '04:15 AM', '04:30 AM', '04:45 AM',
    //             '05:00 AM', '05:15 AM', '05:30 AM', '05:45 AM',
    //             '06:00 AM', '06:15 AM', '06:30 AM', '06:45 AM',
    //             '07:00 AM', '07:15 AM', '07:30 AM', '07:45 AM',
    //             '08:00 AM', '08:15 AM', '08:30 AM', '08:45 AM',
    //             '09:00 AM', '09:15 AM', '09:30 AM', '09:45 AM',
    //             '10:00 AM', '10:15 AM', '10:30 AM', '10:45 AM',
    //             '11:00 AM', '11:15 AM', '11:30 AM', '11:45 AM',
    //             '12:00 PM', '12:15 PM', '12:30 PM', '12:45 PM',
    //             '01:00 PM', '01:15 PM', '01:30 PM', '01:45 PM',
    //             '02:00 PM', '02:15 PM', '02:30 PM', '02:45 PM',
    //             '03:00 PM', '03:15 PM', '03:30 PM', '03:45 PM',
    //             '04:00 PM', '04:15 PM', '04:30 PM', '04:45 PM',
    //             '05:00 PM', '05:15 PM', '05:30 PM', '05:45 PM',
    //             '06:00 PM', '06:15 PM', '06:30 PM', '06:45 PM',
    //             '07:00 PM', '07:15 PM', '07:30 PM', '07:45 PM',
    //             '08:00 PM', '08:15 PM', '08:30 PM', '08:45 PM',
    //             '09:00 PM', '09:15 PM', '09:30 PM', '09:45 PM',
    //             '10:00 PM', '10:15 PM', '10:30 PM', '10:45 PM',
    //             '11:00 PM', '11:15 PM', '11:30 PM', '11:45 PM'
    //         ];
    
    //         this.startTimeOptions = result.map(item => ({
    //             label: item, // The display text
    //             value: item  // The actual value used in selection
    //         }));

    //       }

     

    //     /*getAvailableSlots()
    //         .then((result) => {

    //             this.availableSlots = new Map(
    //                 Object.entries(result).map(([date, timesObj]) => [
    //                     date,
    //                     new Map(Object.entries(timesObj))
    //                 ])
    //             );

    //             let dateeTimeMap = new Map();

    //             this.availableSlots.forEach((timeMap, date) => {

    //                 // console.log('i m date' + JSON.stringify(date));
    //                 timeMap.forEach((r1, t2) => {

    //                     // console.log('d1' + JSON.stringify(r1));
    //                     // console.log('d2' + JSON.stringify(t2));
    //                 })
    //                 let times = Array.from(timeMap.keys());
    //                 // console.log('okay okay' + JSON.stringify(times));
    //                 // console.log('okay okay' + JSON.stringify(date));
    //                 dateeTimeMap.set(date, times);
    //             });

    //             // console.log('Converted dateeTimeMap:', JSON.stringify(dateeTimeMap));


    //             // @track dateTimeMap = new Map([

    //             // console.log('Converted :', JSON.stringify(this.dateTimeMap));
    //             this.dateTimeMap = dateeTimeMap;
    //             this.dateTimeMap.forEach((times, date) => {
    //                 // console.log(`Date: ${date}`);
    //                 // console.log('Times:', times);

    //                 // If you want to log each time individually
    //                 times.forEach(time => {
    //                     // console.log(`Time: ${time}`);
    //                 });
    //             });
    //             // // this.availableSlots = result; // Set the data to the tracked property
    //             // // console.log('Available Slots:', JSON.stringify(this.availableSlots));

    //             // this.availableSlots.forEach((timeMap,date) => {
    //             // //   console.log
    //             //     // let times = Array.from(timeMap.keys()); 

    //             //     // dateeTimeMap.set(date, times);
    //             // });
    //             // console.log('eeeeeeeeeeeeeeeeeeeeeeeeeee'+dateeTimeMap);
    //             this.initializeDate();
    //             this.generateDaysForCurrentMonth();
    //             // console.log('connected call back');
    //         })
    //         .catch((error) => {
    //             this.error = error; // Capture and log any error
    //             console.error('Error fetching available slots:', error);
    //         });
    //         */
    // }
    fetchAvailabilities() {
        receiveAllAvailabilities({ rand: 'randomValue' }) // Replace 'randomValue' with your parameter value
            .then((result) => {
                // this.availabilities = result;
                this.startTimeOptions = result.map(item => ({
                    label: item, // The display text
                    value: item  // The actual value used in selection
                }));
                console.log('Options:', this.startTimeOptions);
                console.log('Availabilities:', result);
            })
            .catch((error) => {
                this.error = error;
                console.error('Error fetching availabilities:', error);
            });
    }


    async getPatientRecordTypeID() {
        let tempID = '';
        await receivePatientRecordTypeID().then(res => {
            tempID = res;

        }).catch(error => {
            console.error('Error on fetching patient record type ID:', error);
        });

        this.filterPatients = {
            criteria: [
                {
                    fieldPath: 'RecordTypeId',
                    operator: 'eq',
                    value: tempID
                }
            ]
        }

    }
    //calender code starts
    initializeDate() {
        const currentDate = new Date();
        this.selectedDate = currentDate;
        this.selectedYear = currentDate.getFullYear();
        this.selectedMonth = currentDate.toLocaleString('default', { month: 'short' });
        // console.log("hhh" + this.selectedMonth);
    }

    generateDaysForCurrentMonth() {
        const now = new Date(this.selectedYear, this.getMonthIndex(this.selectedMonth));
        const daysInMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();

        const monthStart = new Date(this.selectedYear, this.getMonthIndex(this.selectedMonth), 1);
        const startDay = monthStart.getDay();
        this.days = [];
        for (let i = 0; i < startDay; i++) {
            this.days.push({ day: '', isPast: true });
        }
        let today = false;
        for (let day = 1; day <= daysInMonth; day++) {
            let pastDay = this.isPastDate(day);
            // console.log("loop " + (!pastDay) + " " + today);

            if (!pastDay && !today) {
                today = true;
                this.thisDay = day;
                this.days.push({
                    day: day,
                    isPast: pastDay,
                    isToday: true
                });
            } else {
                this.days.push({
                    day: day,
                    isPast: pastDay,
                    isToday: false
                });

            }
        }
        const selectedDay = this.thisDay;
        // console.log("i m here" + selectedDay);
        // console.log(this.duration);
        this.clickedDay = selectedDay;

        const date = this.selectedYear + "-" + (this.getMonthIndex(this.selectedMonth) + 1) + "-" + this.clickedDay;
        this.clickedFullDate = date;

        // console.log("Selected Day: ", this.clickedDay);
        let formattedDate = date.replace(/(\d{4})-(\d{2})-(\d{2})/, '$2/$3/$1');
        this.availableTimes = this.dateTimeMap.get(formattedDate) || [];

        // console.log("hummm" + JSON.stringify(this.availableTimes));

        this.setTimeOptions();
    }

    handlePrev() {
        // console.log("clicked prev");
        let currentDate = new Date(this.selectedYear, this.getMonthIndex(this.selectedMonth) - 1);
        this.updateDate(currentDate);
        this.generateDaysForCurrentMonth();
    }

    handleNext() {
        // console.log("clicked next");
        let currentDate = new Date(this.selectedYear, this.getMonthIndex(this.selectedMonth) + 1);
        // console.log(currentDate);
        this.updateDate(currentDate);
        this.generateDaysForCurrentMonth();
    }

    handleSelectedTime(event) {
        // console.log("clicked");
        const previouslySelected = this.template.querySelector('.selectedtime');
        if (previouslySelected) {
            previouslySelected.classList.remove('selectedtime');
        }
        const clickedElement = event.target;
        clickedElement.classList.add('selectedtime');

    }

    handleSelectedDate(event) {
        const previouslySelected = this.template.querySelector('.selected');
        if (previouslySelected) {
            previouslySelected.classList.remove('selected');
        }
        const clickedElement = event.target;
        clickedElement.classList.add('selected');

        const selectedDay = event.target.dataset.day;
        // console.log(this.duration);
        this.clickedDay = selectedDay;

        const date = this.selectedYear + "-" + (this.getMonthIndex(this.selectedMonth) + 1) + "-" + this.clickedDay;
        this.clickedFullDate = date;

        // console.log("Selected Day: ", this.clickedDay);
        let formattedDate = date.replace(/(\d{4})-(\d{2})-(\d{2})/, '$2/$3/$1');
        this.availableTimes = this.dateTimeMap.get(formattedDate) || [];

        // console.log("hummm" + JSON.stringify(this.availableTimes));

        this.setTimeOptions();
    }

    setTimeOptions() {

        let formattedDate = this.clickedFullDate.replace(/(\d{4})-(\d+)-(\d+)/, (_, year, month, day) => {
            return `${parseInt(month)}/${parseInt(day)}/${year}`;
        });

        this.availableTimes = this.dateTimeMap.get(formattedDate) || [];

        this.timeOptions = this.availableTimes.map(time => {
            if (parseInt(time, 10) > 12) {
                time = parseInt(time, 10) - 12;
                // console.log(time);
                time = time + ":00 PM";
            } else {
                time = time + " AM";
            }
            return { label: time, value: time };
        });
        // this.dateTimeMap.forEach(t=>{
        //     if(this.clickedFullDate == )
        //     timeOptionss.push({
        //         label: t,
        //         value: t
        //     });
        // });
        // this.timeOptions = timeOptionss;

        // console.log("time options: ", JSON.stringify(this.timeOptions));
    }


    updateDate(date) {
        this.selectedYear = date.getFullYear();
        this.selectedMonth = date.toLocaleString('default', { month: 'short' });
        // console.log("update from" + this.selectedMonth)
    }

    getMonthIndex(month) {
        return new Date(Date.parse(month + " 1, 2020")).getMonth();
    }

    isPastDate(day) {
        const monthIndex = this.getMonthIndex(this.selectedMonth);
        // console.log("i m month" + monthIndex);
        // console.log(this.selectedYear);

        const selectedDate = new Date(this.selectedYear, monthIndex, day);

        const date = this.selectedYear + "-" + (this.getMonthIndex(this.selectedMonth) + 1) + "-" + day;
        let formattedDate = date.replace(/(\d{4})-(\d+)-(\d+)/, (_, year, month, day) => {
            return `${parseInt(month)}/${parseInt(day)}/${year}`;
        });

        // console.log("oo" + formattedDate);
        const availableTimes = this.dateTimeMap.get(formattedDate) || [];

        // console.log("i m " + availableTimes.length);
        // console.log(JSON.stringify(availableTimes));

        selectedDate.setHours(0, 0, 0, 0);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        // console.log(selectedDate + " " + today);
        // console.log("i m proma");
        // console.log(selectedDate + " " + today);
        // console.log(availableTimes.length);
        // console.log((selectedDate < today) + " " + availableTimes.length);
        return ((selectedDate < today) || (availableTimes.length == 0));
    }
    handleTimeSelect(event) {
        this.selectedTime = event.detail.value;
        // console.log("Selected Time: ", this.selectedTime);
    }
    handleTimeChange(event) {
        this.selectedTime = event.detail.value;
        // console.log("Selected Time: ", this.selectedTime);
    }




    loadMarginStyle() {
        this.marginStyle = 'margin-inline: 20px;';
    }


    setClinicLocation(event) {
        this.location = event.detail.value;

    }


    handleLocationSearchClick(event) {
        this.spinner = true;
        this.searchLocation(this.location);
    }

    handlepatientAddress(event) {
        this.address = event.detail.value;

    }


    async searchLocation(originAddress) {
        try {
            const result = await retrieveClosestClinicLocationId({ originAddress: originAddress });
            this.closestClinicId = result;
            // console.log('result-->', res);

            if (this.closestClinicId == null) {
                this.ClinickNotFoundMsg = "Clinic not found with this location"
            } else {
                this.ClinickNotFoundMsg = "";

            }
            this.spinner = false;

            this.activeTab = '2'

        } catch (error) {
            console.error('Error fetching closest clinic:', error);
            this.spinner = false;
        }
    }

    handleSuccess(event) {

        this.spinner = true;

        if (!this.fromCalendar) {
            this.closeBtnOnClick();
        }

        this.sendCloseTrigger();
    }

    handleError(event) {
        console.error('Form submission failed');
        console.error('Error message:', event.detail.error.message);
    }

    handleActiveTab(event) {
        if (!this.fromCalendar) {
            this.accountID = this.recordId;
        }

        this.activeTab = event.target.value;

    }

    closeBtnOnClick() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    closeAppointmentModal(e) {
        e.preventDefault();
        if (!this.fromCalendar) {
            this.closeBtnOnClick();
        }
        this.sendCloseTrigger();
    }


    sendStartTrigger() {
        const event = new CustomEvent('appointmentstart', { detail: { 'close': true } });
        this.dispatchEvent(event);
    }

    sendCloseTrigger() {
        const event = new CustomEvent('appointmentclose', { detail: { 'close': true } });
        this.dispatchEvent(event);
    }

    sendNextTrigger() {
        // this.recordTypeModal = false;
        const event = new CustomEvent('appointmentnext', { detail: { 'close': true } });
        this.dispatchEvent(event);
    }



    dateTime(event) {
        var DateTime = new Date(event.detail.value);
        // console.log("i m date" + JSON.stringify(DateTime.toISOString()));
    }

    date(event) {
        // console.log("i m single date" + event.detail.value);

    }
    time(event) {
        // console.log("i m single time" + event.detail.value);
    }
    handleFormSubmit(event) {
        // console.log("hhhhhhhhhhhhhhhh");
        // event.preventDefault();

        // const fields = event.detail.fields;
        // console.log(fields.Date_and_Time_Temp__c);

        // var DateTime = new Date(fields.Date_and_Time_Temp__c);


        // fields.Date_and_Time_Temp__c = DateTime.toISOString();
        // console.log(fields.Date_and_Time_Temp__c);

        // this.template.querySelector('lightning-record-edit-form').submit(fields);
        // this.form = false;
        // this.calender = true;
        event.preventDefault();
        if (!this.fromCalendar) {
            this.closeBtnOnClick();
        }
        this.sendCloseTrigger();
    }

    handleOpenNewModal(e) {
        // this.recordTypeModal = false;
        this.newAppModal = true;
        //             e.preventDefault();
        //    console.log(this.newAppointmentModal);
        //    this.sendNextTrigger();
        // console.log("on child" + this.newAppointmentModal);
        //  this.newAppointmentModal = true;
        //  this.newRecordTypeModal = false;



    }
    check() {
        // console.log("i m in check");
    }




    async fetchAllCareCategories() {
        await receiveAllCareCategories({ rand: Math.random() }).then(results => {
            // console.log('fetchAllCareCategories results:', results);
            if (results.length > 0) {
                this.allCareCategories = results.map(item => ({
                    label: item.Name,
                    value: item.Id
                }));
            } else {
                this.allCareCategories.push({
                    label: 'No Categories',
                    value: 'id'
                });
            }
        }).catch(error => {
            console.error('Error on fetchAllCareCategories:', error);
        });
    }

    async fetchAllAffiliatedGroups() {
        await receiveAllAffiliatedGrps({ rand: Math.random() }).then(results => {
            // console.log('fetchAllAffiliatedGroups results:', results);
            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }

                this.allGroups = results;
            } else {
                tempArr.push({ label: 'No Groups', value: 'id' });
            }
            this.grpOptions = tempArr;
            this.grpOptionsUnavailable = tempArr;

        }).catch(error => {
            console.error('Error:', error);
        });
    }

    async fetchAllAppTypes() {
        await receiveAllAppTypes({ rand: Math.random() }).then(results => {
            // console.log(JSON.stringify(results));
            // console.log('fetchAllAppTypes results:', results);

            let tempArr = [];
            if (results.length > 0) {
                let duration = '';
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }

                this.allAppTypes = results;
            } else {
                tempArr.push({ label: 'Unavailable', value: 'id' });
            }
            this.appTypesOptions = tempArr;

        }).catch(error => {
            console.error('Error:', error);
        });
    }

    async fetchAllGrpLocations() {
        await receiveAllGrpLocations({ rand: Math.random() }).then(results => {
            // console.log('fetchAllGrpLocations results:', results);
            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }

                this.allGrpLocations = results;
            } else {
                tempArr.push({ label: 'Unavailable', value: 'id' });
            }
            this.grpLocationOps = tempArr;
            this.grpLocationOpsUnavailable = tempArr;
        }).catch(error => {
            console.error('Error on fetchAllCareCategories:', error);
        });
    }

    async fetchAllProviderTypes() {
        await receiveAllProviderTypes({ rand: Math.random() }).then(results => {
            // console.log(JSON.stringify(results));
            // console.log('fetchAllProviderTypes results:', results);


            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }

                this.allProviderTypes = results;
            } else {
                tempArr.push({ label: 'Unavailable', value: 'id' });
            }
            this.providerTypeOptions = tempArr;
            this.providerTypeOptionsUnavailable = tempArr;

        }).catch(error => {
            console.error('Error:', error);
        });
    }

    async fetchAllProviders() {
        await receiveAllProviders({ rand: Math.random() }).then(results => {
            // console.log(JSON.stringify(results));
            // console.log('fetchAllProviders results:', results);

            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }

                this.allProviders = results;
            } else {
                tempArr.push({ label: 'Unavailable', value: 'id' });
            }
            this.providerOptions = tempArr;
            this.providerOptionsUnavailable = tempArr;
        }).catch(error => {
            console.error('Error:', error);
        });
    }


    filterAllAppTypes(careIDs) {
        console.log('Entered Care IDs: ', careIDs);
    
        this.appTypesOptions = [];
    
        for (const element of this.allAppTypes) {
            if (careIDs.some(care => care.value === element.Resource_Category__c)) {
                this.appTypesOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }
    
        const isSelectedAppTypeIDValid = this.appTypesOptions.some(
            option => option.value === this.selectedAppTypeID
        );
    
        if (!isSelectedAppTypeIDValid) {
            this.selectedAppTypeID = '';
        }
    
        if (this.appTypesOptions.length === 0) {
            this.appTypesOptions.push({
                label: 'No Appointment Type Found',
                value: ''
            });
            this.selectedAppTypeID = '';
        }
    
        if (this.selectedAppTypeID !== '') {
            const selectedAppType = this.allAppTypes.find(({ Id }) => Id === this.selectedAppTypeID);
    
            if (selectedAppType) {
                this.selectedDuration = selectedAppType.Duration__c;
                this.duration = selectedAppType.Duration__c.split(' ')[0];
            }
        }
        



       // this.filterPTypeUsingCareCAndGLocation();
          this.filterAllProviderTypes(this.allCareCategories,this.selectedgrpLocationID);
        // if (this.selectedgrpLocationID === '') {
        //     this.filterGroupsOfACareCat(this.selectedCareCatID);
        // } else {
        //     this.filterGroupsOfACareCat(this.selectedCareCatID);
        //     this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID, this.selectedgrpLocationID);
        // }
    }


  
    filterAppTypes(careID) {
         console.log('Entered Care ID: ', careID);
        

        this.appTypesOptions = [];

        for (const element of this.allAppTypes) {
            if (element.Resource_Category__c == careID) {
                this.appTypesOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }
       // this.value = JSON.stringify(appTypesOptions);
        const isSelectedAppTypeIDValid = this.appTypesOptions.some(
            option => option.value === this.selectedAppTypeID
        );

        // Update selectedAppTypeID only if it is invalid
        if (!isSelectedAppTypeIDValid) {
            this.selectedAppTypeID = '';
            // this.selectedAppTypeID = this.appTypesOptions.length > 0 ? this.appTypesOptions[0].value : '';
        }

        // console.log('Entered Selected APP Type ID: ', this.selectedAppTypeID);

        if (this.appTypesOptions.length == 0) {
            this.appTypesOptions.push({
                label: 'No Appointment Type Found',
                value: ''
            });
            this.selectedAppTypeID = '';
        }


        if (this.appTypesOptions.length >= 1) {
            if( this.selectedAppTypeID == ''){
                //commented by proma
              //  this.selectedAppTypeID = this.appTypesOptions[0].value;
            }
        
        }
        if (this.selectedAppTypeID != '') {
            const selectedAppType = this.allAppTypes.find(({ Id }) => Id === this.selectedAppTypeID);
            this.selectedDuration = selectedAppType.Duration__c;
            this.duration = selectedAppType.Duration__c.split(' ')[0];

        }


        if(this.selectedgrpLocationID == ''){
           this.filterGroupsOfACareCat(this.selectedCareCatID);
           this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID , this.selectedgrpLocationID);
        }else{
            this.filterGroupsOfACareCat(this.selectedCareCatID);
            this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID , this.selectedgrpLocationID);
        }
    }

    filterGroups(careID, toSelect) {
        // console.log('memme '+toSelect);
        if (toSelect === 1) {
            this.selectedGrpID = this.grpOptions[0].value;
        } else {
            this.grpOptions = [];


            // if (this.selectedgrpLocationID) {
            //     for (const element of this.allGrpLocations) {
            //         if (element.Id === this.selectedgrpLocationID) {
            //             for (const elementOfGroups of this.allGroups) {
            //                 if (element.Provider_Company__c == elementOfGroups.Id) {
            //                     this.grpOptions.push({
            //                         label: elementOfGroups.Name,
            //                         value: elementOfGroups.Id
            //                     });
            //                 }
            //             }
            //         }

            //     }
            // } else {
            for (const element of this.allGroups) {
                if (element.Resource_Category__c == careID) {
                    this.grpOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
            }
            // }
            // console.log('Group Options: ', this.grpOptions)
            const isSelectedGrpIDValid = this.grpOptions.some(
                option => option.value === this.selectedGrpID
            );

            // Update selectedGrpID only if it is invalid
            if (!isSelectedGrpIDValid) {
                this.selectedGrpID = '';
                this.groupAddress = '';
                // this.selectedGrpID = this.grpOptions.length > 0 ? this.grpOptions[0].value : '';
            }

            // if (this.grpOptions.length == 0) {
            //     this.grpOptions.push({
            //         label: 'No Group',
            //         value: 'id'
            //     });
            // }

            if (this.grpOptions.length < 1) {
                this.grpOptions = [{
                    label: 'No Affiliated Group Found',
                    value: ''
                }];

                this.selectedGrpID = '';
                this.groupAddress = '';
            } else if (toSelect == 1) {
                // console.log('memme in'+toSelect+ ' l '+ this.grpOptions[0].value);
                this.selectedGrpID = this.grpOptions[0].value; // changed by proma marked  as a bug (when called from care cat handler)
            }
        }



    }

    filterGroupByLocation(grpID) {
        // this.grpOptions = [];
        for (const element of this.allGroups) {
            if (element.Id == grpID) {
                this.selectedGrpID = element.Id;
                break;
            }
        }
        console.log('this.selectedGrpID-->', this.selectedGrpID);


        // if (this.grpOptions.length == 0) {
        //     this.grpOptions.push({
        //         label: 'No Group',
        //         value: 'id'
        //     });
        // }

    }


    filterGroupLocations(groupID) {
        console.log('hlwww care cat'+this.selectedCareCatID);
        this.grpLocationOps = [];
        // console.log('this.allGrpLocations-->', JSON.stringify(this.allGrpLocations));
        if (groupID) {
            console.log('in if');
            for (const element of this.allGrpLocations) {
                if (element.Provider_Company__c == groupID) {
                    this.grpLocationOps.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
            }
        } else {
            console.log('in else');
            for (const groupOption of this.grpOptions) {
                for (const element of this.allGrpLocations) {
                    if (element.Provider_Company__c === groupOption.value) {
                        this.grpLocationOps.push({
                            label: element.Name,
                            value: element.Id
                        });
                    }
                }
            }
        }

        const isSelectedGrpLocationIDValid = this.grpLocationOps.some(
            option => option.value === this.selectedgrpLocationID
        );

        // Update selectedgrpLocationID only if it is invalid
        if (!isSelectedGrpLocationIDValid) {
            this.selectedgrpLocationID = '';
            // this.selectedgrpLocationID = this.grpLocationOps.length > 0 ? this.grpLocationOps[0].value : null;
        }

        if(this.grpLocationOps.length >0){
           this.selectedgrpLocationID = this.grpLocationOps[0].value;
        }

        // if (this.grpLocationOps.length == 0) {
        //     this.grpLocationOps.push({
        //         label: 'No Locations',
        //         value: 'id'
        //     });
        // }

        //nilufa
      
    
        this.filterCareCatFromLocation(this.selectedgrpLocationID );


    }

    filterProviderTypes() {
        this.providerTypeOptions = [];
        if (this.selectedCareCatID == null || this.selectedAppTypeID == null || this.selectedgrpLocationID == null) {
            return;
        }

        // console.log('this.allProviderTypes-->', JSON.stringify(this.allProviderTypes));

        for (const element of this.allProviderTypes) {
            if (element.Resource_Category__c == this.selectedCareCatID && element.Clinic_Location__c == this.selectedgrpLocationID ) {
                this.providerTypeOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }

        // if (this.providerTypeOptions.length == 0) {
        //     this.providerTypeOptions.push({
        //         label: 'No Types',
        //         value: 'id'
        //     });
        // }

    }

    filterAllProviderTypes(careIDs, selectedgrpLocationID) {
        this.providerTypeOptions = [];
        
        if (!careIDs.length || !selectedgrpLocationID) {
            return;
        }
    
        for (const element of this.allProviderTypes) {
            if (
                careIDs.some(care => care.value === element.Resource_Category__c) 
            ) {
                this.providerTypeOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }
    
        this.filterAllProviders(careIDs,this.providerTypeOptions,selectedgrpLocationID);
    }

    // filterAllProviders(careIDs, selectedgrpLocationID) {
    //     this.providerOptions = [];
        
    //     if (!careIDs.length || !selectedgrpLocationID) {
    //         return;
    //     }
    
    //     for (const element of this.allProviders) {
    //         if (
    //             careIDs.some(care => care.value === element.Resource_Category__c) &&
    //             element.Clinic_Location__c === selectedgrpLocationID
    //         ) {
    //             this.providerOptions.push({
    //                 label: element.Name,
    //                 value: element.Id
    //             });
    //         }
    //     }
    
    //     if (this.providerOptions.length > 0) {
    //         this.selectedProvider = this.providerOptions[0].value;
    //     }
    // }
    @track checkk = '';

    filterAllProviders(careIDs, providerTypeIDs, selectedgrpLocationID) {
      
        // this.providerOptions.push({
        //     label: 'rrr',   // Assuming 'Name' is the provider's display name
        //     value: this.checkk    // Assuming 'Id' is the provider's unique identifier
        // })
        // console.log('this.allGrpLocations-->', JSON.stringify(this.allGrpLocations));
        // if (this.selectedCareCatID == null || this.selectedAppTypeID == null || this.selectedgrpLocationID == null || this.selectedGrpID == null || this.selectedProviderTypeID == null) {
        //     return;
        // }
         
        receiveCareCategoriesOfClinic({ locationId: selectedgrpLocationID })
        .then(result => {
            this.providerOptions = [];
          // console.log();
       //   this.checkk = JSON.stringify(result);
            for (const element of this.allProviders) {
            const careCat = element.Resource_Type__r.Resource_Category__c;
       //     this.checkk  = careCat;
        
  
            const clinicLocation = element.clinic_location;

            // Check if any record in the result matches both careCat and clinicLocation
            const exists = result.some(item => 
                item.Id== careCat
            );
            if (exists) {
                this.providerOptions.push({
                    label: element.Name,   // Assuming 'Name' is the provider's display name
                    value: element.Id      // Assuming 'Id' is the provider's unique identifier
                });
            }
            
}
        })
    }
    filterProviers() {
        this.providerOptions = [];
        // console.log('this.allGrpLocations-->', JSON.stringify(this.allGrpLocations));
        // if (this.selectedCareCatID == null || this.selectedAppTypeID == null || this.selectedgrpLocationID == null || this.selectedGrpID == null || this.selectedProviderTypeID == null) {
        //     return;
        // }

        for (const element of this.allProviders) {
            if(this.selectedgrpLocationID != ''){
                if (element.Clinic_Location__c == this.selectedgrpLocationID && element.Resource_Type__c == this.selectedProviderTypeID ) {
                    this.providerOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
            }else{

                if (element.Resource_Type__c == this.selectedProviderTypeID ) {
                    this.providerOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
            }
    
        }

if( this.providerOptions.length > 0){
    this.selectedProvider  = this.providerOptions[0].value;
}
        // if (this.grpLocationOps.length == 0) {
        //     this.grpLocationOps.push({
        //         label: 'No Locations',
        //         value: 'id'
        //     });
        // }

    }

    handlePatientChange(event) {
       
        this.appointment.Patient_Account__c = event.detail.recordId;
        //console.log('this.appointment.Patient__c-->', this.appointment.Patient_Account__c);
    }

    handleCareCatChange(event) {
        this.selectedCareCatID = event.detail.value;
        console.log( this.selectedCareCatID );
        this.appointment.Resource_Category__c = event.detail.value;
        this.selectedgrpLocationID = '';
        this.selectedAppTypeID = '';
        this.selectedGrpID = '';
        this.selectedProviderTypeID = '';
        this.selectedProvider = '';
        this.filterAppTypes(event.detail.value);
     //   this.filterGroupsOfACareCat(this.selectedCareCatID);
    //     this.filterGroups(event.detail.value, 2);
    //   this.filterGroupLocations(this.selectedGrpID); 
    //     this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID, this.selectedgrpLocationID)
    //     this.filterProviderUsingCCat(this.selectedAppTypeID, this.selectedProviderTypeID, this.selectedgrpLocationID);

        //    this.filterGroupLocationsByCCat(event.detail.value);
        // this.filterProviderTypeUsingCareCat();

        // this.filterProviderTypeUsingCCat(event.detail.value);
       
        // this.filterProviderTypes();
        // this.filterProviers();
    
        if (this.selectedDate != '') {
            this.getProviders(this.startTime);
        };
        this.checkStartDateEnable();

        if (this.selectedgrpLocationID == '') {
            this.groupAddress = '';
        }
        if (this.selectedAppTypeID == '') {
            this.selectedDuration = '';
        }

    }
     groupLocationList = [];
    filterGroupsOfACareCat(grpLocationId){

        receiveGrpLocationsOfACareCat({ careCatId: grpLocationId })
        .then(result => {


          // console.log('hiii '+result.length);
            this.groupLocationList = result; // Store the result
           // this.error = undefined; // Clear any previous errors
            // this.allGroups = [];
            this.grpLocationOps = result.map(location => ({
                label: location.Name, // Display Name as label
                value: location.Id // Use Id as value
            }));

            if(  this.selectedgrpLocationID == ''){
               //commented by nilufa
              // this.selectedgrpLocationID = this.grpLocationOps[0].value;
            }
             

            this.filterGroupsOnLocationBase();
            //this.selectedCareCatID = 
           //  this.selectedCareCatID = this.allCareCategories[0].value;
           //  this.filterAppTypes(this.selectedCareCatID);  //p 
     
    //  //    this.value = ' gggggggggggggggggggggggggggggggg';
    //         if (this.allCareCategories.length > 0) {
    //         //     this.selectedCareCatID = this.allCareCategories[0].value;
     
    //         //  this.selectedAppTypeID = 'a3OWr000001R1sHMAS';
    //          // this.filterAppTypes(this.selectedCareCatID);  //p 
    //         }else{

    //             this.allCareCategories =  [{
    //                 label: 'No Care Category Available', // Display Name as label
    //                 value: '.' // Empty value
    //             }];
    //             this.selectedCareCatID = this.allCareCategories[0].value;
                  
     
    //         }
        })
        .catch(error => {
            // this.allCareCategories =  [{
            //     label: 'No ', // Display Name as label
            //     value: '.' // Empty value
            // }];
          //  this.selectedCareCatID = this.careCategoryList[0].value;
         //   this.error = error.body.message; // Capture and display the error message
           // this.careCategoryList = []; // Clear the list in case of error
        });



    }

    filterGroupsOnLocationBase(){

        // this.grpLocationOps.forEach(locationOp => {
           
        //    const targetId  = locationOp.value;
        //    this.grpOptions = [];
        //    const matchingGroup = this.allGroups.find(group => group.Id === targetId);
        //    if (matchingGroup) {
        //     // // If found, store the Name and Id
        //     // const storedName = matchingGroup.Name;
        //     // const storedId = matchingGroup.Id;
        //     // console.log(`Found group: Name = ${storedName}, Id = ${storedId}`);
        //     this.grpOptions.push({label:matchingGroup.Name})
        // } else {
        //     console.log(`ID ${targetId} does not exist in the list.`);
        // }


        // });
      //  this.grpOptions = [];
        this.groupLocationList.forEach(location => {
            // Access and perform operations on each location
           // console.log(`Location Id: ${location.Id}, Name: ${location.Name}`);
           const targetId  = location.Provider_Company__c;
           
     
           const matchingGroup = this.allGroups.find(group => group.Id === targetId);
    
                 if (matchingGroup) {
            // // If found, store the Name and Id
            // const storedName = matchingGroup.Name;
            // const storedId = matchingGroup.Id;
            // console.log(`Found group: Name = ${storedName}, Id = ${storedId}`);
           // this.grpOptions.push({label:matchingGroup.Name, value: matchingGroup.Id})
            if( location.Id== this.selectedgrpLocationID){
                this.selectedGrpID = matchingGroup.Id
               }

        } else {
            console.log(`ID ${targetId} does not exist in the list.`);
        }
        });

          this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID, this.selectedgrpLocationID)
        

        
    }
    handleCareCatChangeU(event) {
        this.selectedCareCatU = event.detail.value;
        this.appointment.Resource_Category__c = event.detail.value;
        this.selectedGrpLocationU = '';
        this.selectedGroupU = '';
        this.selectedProviderTypeU = '';
        this.selectedProviderU = '';
        this.filterGroupsUnavailable(this.selectedCareCatU);
        this.filterGroupLocationsUnavilable(this.selectedGroupU);
        this.filterProviderTypeUCCatAndAppTypeUnavailable(this.selectedCareCatU, this.selectedGrpLocationU);
        this.filterProviderUsingCCatUnavailable(this.selectedProviderTypeU, this.selectedGrpLocationU);
        if (this.selectedDateU != '') {
            this.getProvidersUnavailable(this.startTimeU);
        };
        this.checkStartDateEnable();
    }

    handleGroupChangeU(event) {

        this.selectedGroupU = event.detail.value;
        this.appointment.Provider_Company__c =  this.selectedGroupU;
        this.appointment.Provider_Company__c = event.detail.value;
     
        for (const element of this.allGroups) {
            if (element.Id == this.selectedGroupU) {
                // console.log('uuu' +element.Resource_Category__c);
                this.selectedCareCatU = element.Resource_Category__c;

                this.appointment.Resource_Category__c = element.Resource_Category__c;
                this.filterGroupLocationsUnavilable(this.selectedGroupU);
                this.filterProviderTypeUCCatAndAppTypeUnavailable(this.selectedCareCatU, this.selectedGrpLocationU);
                this.filterProviderUsingCCatUnavailable(this.selectedProviderTypeU, this.selectedGrpLocationU);
            }
        }
    }

    handleGroLocationChangeU(event) {
        this.selectedGrpLocationU = event.detail.value;
        this.appointment.Clinic_Location__c = event.detail.value;
        let selectedLocationObj = null;
        for (const element of this.allGrpLocations) {
            if (element.Id == event.detail.value) {
                selectedLocationObj = element;
                break;
            }
        }
        this.groupAddressU = selectedLocationObj.Address_Text__c;
        for (const element of this.allGroups) {
            if (element.Id == selectedLocationObj.Provider_Company__c) {
                this.selectedCareCatU = element.Resource_Category__c;
                this.selectedGroupU = element.Id;
                this.filterProviderTypeUCCatAndAppTypeUnavailable(this.selectedCareCatU, this.selectedGrpLocationU);
                this.filterProviderUsingCCatUnavailable(this.selectedProviderTypeU, this.selectedGrpLocationU);
                break;
            }
        }
        if (this.selectedDateU != '') {
            this.getProvidersUnavailable(this.startTimeU);
        };
        this.checkStartDateEnable();
    }

    handleProviderTypeChangeU(event) {
        this.selectedProviderTypeU = event.detail.value;
        this.appointment.Resource_Type__c = event.detail.value;
        console.log(this.allGrpLocations);
        for (const element of this.allProviderTypes) {
            console.log('Group location Ids: ',element.Clinic_Location__c);
            if (element.Id == event.detail.value) {
                console.log(element.Clinic_Location__c);
                if(element.Clinic_Location__c != null) {
                    this.selectedGrpLocationU = element.Clinic_Location__c;
                    this.appointment.Clinic_Location__c = element.Clinic_Location__c;
                    // this.groupAddressU = element.Clinic_Location__r.Address_Text__c;
                    this.selectedCareCatU = element.Resource_Category__c;
                    const selectedLocation = this.allGrpLocations.find(location => location.Id === this.selectedGrpLocationU);
                    this.selectedGroupU = selectedLocation.Provider_Company__c;
                    this.filterProviderUsingCCatUnavailable(this.selectedProviderTypeU, this.selectedGrpLocationU);
                } else {
                    this.selectedCareCatU = element.Resource_Category__c;
                    this.selectedGrpLocationU = '';
                    this.filterProviderUsingCCatUnavailable(this.selectedProviderTypeU, this.selectedGrpLocationU);
                    this.selectedGrpLocationU = 'No Group Location Provided or closed';
                    this.selectedGroupU = 'No Group Provided';
                }
            }
        }
        if (this.selectedDateU != '') {
            this.getProvidersUnavailable(this.startTimeU);
        };
        this.checkStartDateEnable();
    }

    handleProviderChangeU(event) {
        this.appointment.Clinic_Resource__c = event.detail.value;
        this.selectedProviderU = event.detail.value;
        for (const element of this.allProviders) {
            if (element.Id == event.detail.value) {
                this.appointment.Resource_Category__c = element.Resource_Category__c;

               // this.selectedCareCatU = element.Clinic_Location__r.Provider_Company__r.Resource_Category__c;
               this.selectedCareCatU = element.Resource_Type__r.Resource_Category__c;


                this.selectedGroupU = element.Clinic_Location__r.Provider_Company__c;
                // this.selectedAppTypeID = element.Appointment_Type__c;
                // const selectedAppType = this.allAppTypes.find(({ Id }) => Id === this.selectedAppTypeID);
                // this.selectedDuration = selectedAppType.Duration__c;
                // this.duration = selectedAppType.Duration__c.split(' ')[0];
                // if (this.startTime && this.selectedAppTypeID) {
                //     this.endTime = this.calculateEndTime(this.startTime, this.duration);
                //     this.appointment.End_Time__c = this.endTime;
                // }
                this.selectedGrpLocationU = element.Clinic_Location__c;
                this.selectedProviderTypeU = element.Resource_Type__c;
                this.groupAddressU = element.Clinic_Location__r.Address_Text__c;
                if (this.providerTypeOptionsUnavailable.length < 1) {
                  
                    this.selectedProviderTypeU = '';
                } else {
                    console.log('nijhum')
                    this.providerTypeOptionsUnavailable = this.providerTypeOptionsUnavailable.filter(option => option.value !== '');

                    this.selectedProviderTypeU = element.Resource_Type__c;
                }
            }
        }
        this.checkStartDateEnable();
    }

    handleDateChangeU(event) {
        this.appointment.Appointed_Date__c = event.detail.value;
        this.selectedDateU = event.detail.value;
        this.isStartTimeDisabled = false;
        const selectedDate = new Date(this.selectedDateU);
        const today = new Date();
        today.setHours(0, 0, 0, 0); // Reset time for comparison

        if (selectedDate < today) {
            // If selected date is in the past, mark Start Time as invalid
            this.isStartTimeInvalid = true;
        } else {
            ;
            this.isStartTimeInvalid = false;
        }
        const timeToUse = this.startTimeU || '';
        this.getProvidersUnavailable(timeToUse);
        this.checkStartDateEnable();
    }

    filterGroupsUnavailable(careID) {
        this.grpOptionsUnavailable = [];
        for (const element of this.allGroups) {
            if (element.Resource_Category__c == careID) {
                this.grpOptionsUnavailable.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }
        const isSelectedGrpIDValid = this.grpOptionsUnavailable.some(
            option => option.value === this.selectedGroupU
        );

        // Update selectedGrpID only if it is invalid
        if (!isSelectedGrpIDValid) {
           
           this.selectedGroupU = this.grpOptionsUnavailable.length > 0 ? this.grpOptionsUnavailable[0].value : '';
        }

        if (this.grpOptionsUnavailable.length < 1) {
            this.grpOptionsUnavailable = [{
                label: 'No Affiliated Group Found',
                value: ''
            }];
            this.selectedGroupU = '';
        }
    }

    filterGroupLocationsUnavilable(groupID) {
        console.log('Group Locations: ', this.grpOptionsUnavailable);
        this.grpLocationOpsUnavailable = [];
        if (groupID) {
            for (const element of this.allGrpLocations) {
                if (element.Provider_Company__c == groupID) {
                    this.grpLocationOpsUnavailable.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
            }
        } else {
            for (const groupOption of this.grpOptionsUnavailable) {
                for (const element of this.allGrpLocations) {
                    if (element.Provider_Company__c === groupOption.value) {
                        this.grpLocationOpsUnavailable.push({
                            label: element.Name,
                            value: element.Id
                        });
                    }
                }
            }
        }

        const isSelectedGrpLocationIDValid = this.grpLocationOpsUnavailable.some(
            option => option.value === this.selectedGrpLocationU
        );
        if (!isSelectedGrpLocationIDValid) {
            if (this.grpLocationOpsUnavailable.length > 0) {
                //this.selectedProviderTypeU = this.providerTypeOptionsUnavailable[0].value;
                this.selectedGrpLocationU = '';
            } else {
                this.grpLocationOpsUnavailable = [{
                    label: 'No Provider Type Found',
                    value: ''
                }];
                this.selectedGrpLocationU = this.grpLocationOpsUnavailable[0].value;
            }
        }
    }

    filterProviderTypeUCCatAndAppTypeUnavailable(selectedCareCatU, selectedGrpLocationU) {
        this.providerTypeOptionsUnavailable = [];
        let count = 1;
        for (const element of this.allProviderTypes) {
            // console.log('Passed parameters in ProviderType: ', selectedCareCatID, ' ', selectedAppTypeID, ' ', selectedGrpLocationU)
            if (selectedGrpLocationU !== '') {
                if (element.Resource_Category__c == selectedCareCatU &&
                    element.Clinic_Location__c == selectedGrpLocationU) {
                    this.providerTypeOptionsUnavailable.push({
                        label: element.Name,
                        value: element.Id
                    });
                    // console.log('Provider Options 1 un' + (count++) +' : ', this.providerTypeOptionsUnavailable);
                }

            } else {
                if (element.Resource_Category__c == selectedCareCatU) {
                    this.providerTypeOptionsUnavailable.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
                // console.log('Provider Options 2 un: ', this.providerTypeOptionsUnavailable);
            }
        }
        // console.log('Provider Options length un: ', this.providerTypeOptionsUnavailable.length);

        // Fallback logic - only runs after the loop
        const isSelectedProviderTypeIDValid = this.providerTypeOptionsUnavailable.some(
            option => option.value === this.selectedProviderTypeU
        );

        // Update selectedProviderTypeID only if it is invalid
        if (!isSelectedProviderTypeIDValid) {
            if (this.providerTypeOptionsUnavailable.length > 0) {
                //this.selectedProviderTypeU = this.providerTypeOptionsUnavailable[0].value;
            } else {
                this.providerTypeOptionsUnavailable = [{
                    label: 'No Provider Type Found',
                    value: ''
                }];
                this.selectedProviderTypeU = '';
            }
        }
    }

    filterProviderUsingCCatUnavailable(selectedProviderTypeU, selectedGrpLocationU) {
        this.providerOptionsUnavailable = [];
        console.log(this.allProviders);
        // Filter providers
        for (const element of this.allProviders) {
            if (element.Resource_Type__c == selectedProviderTypeU &&
                element.Clinic_Location__c == selectedGrpLocationU) {
                this.providerOptionsUnavailable.push({
                    label: element.Name,
                    value: element.Id
                });
            } else if (element.Clinic_Location__r.Provider_Company__r.Resource_Category__c == this.selectedCareCatU &&
                this.selectedGrpLocationU == element.Clinic_Location__c && this.selectedProviderTypeU == '' ) {
                    this.providerOptionsUnavailable.push({
                        label: element.Name,
                        value: element.Id
                    });
            } 
            else if (element.Clinic_Location__r.Provider_Company__r.Resource_Category__c == this.selectedCareCatU &&
                this.selectedGrpLocationU == '' && this.selectedProviderTypeU == '' ) {
                this.providerOptionsUnavailable.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }

        // Check if the current selectedProvider is still valid
        const isSelectedProviderValid = this.providerOptionsUnavailable.some(
            option => option.value === this.selectedProviderU
        );

        // Update selectedProvider only if it is invalid
        if (!isSelectedProviderValid) {
            if (this.providerOptionsUnavailable.length > 0) {
               // this.selectedProviderU = this.providerOptionsUnavailable[0].value; // Set to first valid option
            } else {
                // No providers found, add fallback option
                this.providerOptionsUnavailable = [{
                    label: 'No Provider Found',
                    value: ''
                }];
                this.selectedProviderU = ''; // Reset selectedProvider
            }
        }



        if (this.selectedDate != null && this.selectedTime != '' && this.providerOptionsUnavailable.length >= 1) {
            const timeString = this.selectedTime;
            const [hours, minutes] = timeString.split(':').map(Number);

            // Create a Date object for the time
            const timeInstance = new Date();
            timeInstance.setHours(hours, minutes, 0, 0); // Set hours, minutes, seconds, and milliseconds

            // console.log(timeInstance); // Example: "2024-12-06T06:15:00.000Z"


        }
        // console.log('Filtered Providers: ', this.providerOptionsUnavailable);
    }

    filterProviderUsingCCat(selectedAppTypeID, selectedProviderTypeID, selectedgrpLocationID) {
        this.providerOptions = [];

        // console.log('Appointment Type: ', selectedAppTypeID, ' Group Location: ', selectedgrpLocationID, ' Provider Type: ', selectedProviderTypeID);
        if (!selectedProviderTypeID) {
            for (const providerType of this.providerTypeOptions) {
                for (const element of this.allProviders) {
                    if (
                        element.Resource_Type__c === providerType.value
                    ) {
                        this.providerOptions.push({
                            label: element.Name,
                            value: element.Id
                        });
                    }
                }
            }
        } else {
            for (const element of this.allProviders) {
                if (
                    element.Resource_Type__c == selectedProviderTypeID &&
                    element.Appointment_Type__c == selectedAppTypeID &&
                    element.Clinic_Location__c == selectedgrpLocationID
                ) {
                    this.providerOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
            }
        }
        // Filter providers


        // Check if the current selectedProvider is still valid
        const isSelectedProviderValid = this.providerOptions.some(
            option => option.value === this.selectedProvider
        );

        // Update selectedProvider only if it is invalid
        if (!isSelectedProviderValid) {
            if (this.providerOptions.length > 0) {
                //commented by nilufa
                //this.selectedProvider = '';
                //commented by p
                //this.selectedProvider = this.providerOptions[0].value;n
            } else {
                // No providers found, add fallback option
                this.providerOptions = [{
                    label: 'No Provider Found',
                    value: ''
                }];
                this.selectedProvider = ''; // Reset selectedProvider
            }
        }



        if (this.selectedDate != null && this.selectedTime != '' && this.providerOptions.length >= 1) {
            const timeString = this.selectedTime;
            const [hours, minutes] = timeString.split(':').map(Number);

            // Create a Date object for the time
            const timeInstance = new Date();
            timeInstance.setHours(hours, minutes, 0, 0); // Set hours, minutes, seconds, and milliseconds

            // console.log(timeInstance); // Example: "2024-12-06T06:15:00.000Z"


        }
        // console.log('Filtered Providers: ', this.providerOptions);
    }

    filterProviderTypeUsingCCat(selectedCareCatID) {
        this.providerTypeOptions = [];


        for (const element of this.allProviderTypes) {
            if (element.Resource_Category__c == selectedCareCatID) {
                this.providerTypeOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }

        if (this.providerTypeOptions.length < 1) {
            this.providerTypeOptions = [{
                label: 'No Provider Type Found',
                value: ''
            }];

            this.selectedProviderTypeID = '';
        }


    }

    handleAppTypeChange(event) {
        // console.log('handleAppTypeChange-->', event.detail.value);


        // console.log('this.duration-->', this.duration);

        // this.filterAppTypes('selectedAppType-->', selectedAppType);
        this.selectedAppTypeID = event.detail.value;
        this.appointment.Appointment_Type__c = event.detail.value;

        const selectedAppType = this.allAppTypes.find(({ Id }) => Id === event.detail.value);

        this.selectedDuration = selectedAppType.Duration__c;
        this.duration = selectedAppType.Duration__c.split(' ')[0];

        if (this.startTime && this.selectedAppTypeID) {
            // console.log('hii ' + this.startTime + this.duration);
            this.endTime = this.calculateEndTime(this.startTime, this.duration);
            // console.log('kkk ' + this.endTime);
            this.appointment.End_Time__c = this.endTime;
            // console.log(this.appointment.End_Time__c);
            // this.isEndTimeDisabled = true;
        }

        for (const element of this.allAppTypes) {
            if (element.Id == this.selectedAppTypeID) {
                this.selectedCareCatID = element.Resource_Category__c;
            }
        }


        // this.filterGroups(this.selectedCareCatID, 2);
        // this.filterGroupLocations(this.selectedGrpID);
        // this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID, this.selectedgrpLocationID);
        // this.filterProviderUsingCCat(this.selectedAppTypeID, this.selectedProviderTypeID, this.selectedgrpLocationID);


        this.filterGroupsOfACareCat(this.selectedCareCatID);

        // console.log('Filtered Groups: ', this.grpOptions);
       
        // this.filterGroupLocationsByCCat(this.selectedCareCatID);
        // console.log('Selected Group ID: ', this.selectedgrpLocationID)

        // this.filterProvidersByCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID);
        // this.filterAppTypes(this.selectedCareCatID);

        // for(const element this.a)



        // this.filterProviderTypes();
        // this.filterProviers();
        if (this.selectedDate != '') {
            console.log('handle app');
            this.getProviders(this.startTime);
        };
        this.checkStartDateEnable();
    }

    filterProviderTypeUCCatAndAppType(selectedCareCatID, selectedAppTypeID, selectedgrpLocationID) {
        console.log(' i mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm               here jiiiii');
        this.providerTypeOptions = [];
        let count = 1;
        for (const element of this.allProviderTypes) {
            // console.log('Passed parameters in ProviderType: ', selectedCareCatID, ' ', selectedAppTypeID, ' ', selectedgrpLocationID)
            if (selectedgrpLocationID !== '' && selectedAppTypeID !== '') {
                if (element.Resource_Category__c == selectedCareCatID &&

                    element.Clinic_Location__c == selectedgrpLocationID) {
                    this.providerTypeOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                    // console.log('Provider Options 1 ' + (count++) +' : ', this.providerTypeOptions);
                }

            } else if (selectedgrpLocationID == '' ) {
                if (element.Resource_Category__c == selectedCareCatID) {
                    this.providerTypeOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
                // console.log('Provider Options 2: ', this.providerTypeOptions);
            } else if (selectedgrpLocationID !== '' && selectedAppTypeID == '') {
                if (element.Resource_Category__c == selectedCareCatID ) {
                    this.providerTypeOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
                // console.log('Provider Options 3: ', this.providerTypeOptions);
            } else {
                if (element.Resource_Category__c == selectedCareCatID) {
                    this.providerTypeOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
                // console.log('Provider Options 4: ', this.providerTypeOptions);
            }
        }
        // console.log('Provider Options length: ', this.providerTypeOptions.length);

        // Fallback logic - only runs after the loop
        const isSelectedProviderTypeIDValid = this.providerTypeOptions.some(
            option => option.value === this.selectedProviderTypeID
        );

        // Update selectedProviderTypeID only if it is invalid
        if (!isSelectedProviderTypeIDValid) {
            if (this.providerTypeOptions.length > 0) {
                //commented by proma
             //   this.selectedProviderTypeID = '';
             if(this.selectedProviderTypeID == ''){
                
               //this.selectedProviderTypeID = this.providerTypeOptions[0].value;
             }
                

                
            } else {
                this.providerTypeOptions = [{
                    label: 'No Provider Type Found',
                    value: ''
                }];
                this.selectedProviderTypeID = '';
            }
        }
    if(this.selectedProvider ==''){
        this.filterProviderUsingCCat(this.selectedAppTypeID, this.selectedProviderTypeID, this.selectedgrpLocationID);

    }


      
        
    }

    filterProvidersByCCatAndAppType(selectedCareCatID, selectedAppTypeID) {

        this.providerOptions = [];
        for (const element of this.allProviders) {
            if (element.Resource_Category__c == selectedCareCatID && element.Appointment_Type__c == selectedAppTypeID) {
                this.providerOptions.push({
                    label: element.Name,
                    value: element.Id
                })
            }
        }
        if (this.providerOptions.length < 1) {
            this.providerOptions = [{
                label: 'No Provider Found',
                value: ''
            }];

            this.selectedProvider = '';
        }
    }


    filterGroupLocationsByCCat(careCatId) {
        this.grpLocationOps = [];
        for (const element of this.allGrpLocations) {
            // console.log(careCatId +' huuuu '+element.Resource_Category__c);
            if (element.Resource_Category__c == careCatId) {


                this.grpLocationOps.push({
                    label: element.Name,
                    value: element.Id
                });


            }


        }


        if (this.grpLocationOps.length < 1) {
            this.grpLocationOps = [{
                label: 'No Group location Found',
                value: ''
            }];

            this.selectedgrpLocationID = '';
        }

    }

    handletelehealthChange(event) {
        this.telehealthDefault = event.detail.value;
        if (this.telehealthDefault == 'Yes') {
            this.isTelehealth = true;
            this.roomTypeOptions = this.placeholderRoomType;
            this.selectedRoomType = '--';
        }
        else {
            this.isTelehealth = false;
            this.roomTypeOptions = this.defaultRoomTypeOptions;
            this.selectedRoomType = this.defaultRoomTypeOptions[0].value;
        }
        this.isGroupRequired = !this.isTelehealth;
        this.appointment.Telehealth__c = event.detail.value;
    }

    handleDateChange(event) {
        this.appointment.Appointed_Date__c = event.detail.value;
        this.isStartTimeDisabled=false;
        this.selectedDate = event.detail.value;
        console.log(this.selectedDate );
        // if (this.selectedDate !== '') {
        //     this.isStartDateDisabled = false;  // Enable Start Date if a date is selected
        // } else {
           
        //         this.isStartDateDisabled = true;
           
        // }
        // if (this.selectedDateU == '') {
        //     this.isStartDateDisabled = true;
        // }
        const selectedDate = new Date(this.selectedDate);
        const today = new Date();
        today.setHours(0, 0, 0, 0); // Reset time for comparison

        if (selectedDate < today) {
            // If selected date is in the past, mark Start Time as invalid
            // console.log('selected Date < today');
            this.isStartTimeInvalid = true;
        } else {
            // console.log('selected Date > today');
            this.isStartTimeInvalid = false;
        }
        // console.log('Start Time before getting providers --> ', this.startTime)
        const timeToUse = this.startTime || '';
        this.getProviders(timeToUse);
        this.checkStartDateEnable();
       
    }

    handleGroupChange(event) {
        console.log('hlw nijhum');
        console.log('care cat'+this.selectedCareCatID);
        // console.log('handleGroupChange-->', event.detail.value);
        this.selectedGrpID = event.detail.value;
        this.appointment.Provider_Company__c = event.detail.value;
        
        
        this.filterGroupLocations(this.selectedGrpID);


        //this.filterCareCat(this.selectedGrpID);
        //0 this.filterGroupLocations(event.detail.value);


        // this.filterProviers();
        // console.log('haha');
        //1 this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID, this.selectedgrpLocationID);
        //1 this.filterProviderUsingCCat(this.selectedProviderTypeID);
        // this.filterPTypeUsingGTypeAndCareCat(this.selectedGrpID,this.selectedCareCatID);
        // this.filterProviderUsingGTypeAndCareCat(this.selectedGrpID,this.selectedCareCatID);
    
    
    
        if (this.selectedDate != '') {
            this.getProviders(this.startTime);
        };
        this.checkStartDateEnable();
        if (this.selectedgrpLocationID == '') {
            this.groupAddress = '';
        }

    }


    filterPTypeUsingGTypeAndCareCat(selectedGrpID, selectedCareCatID) {
        //    = this.allGroups.find(({ Id }) => Id === selectedGrpID);

        for (const element of this.allProviderTypes) {
            if (element.Resource_Category__c == selectedCareCatID) {
                var locationId = element.Clinic_Location__c;


                for (const element2 of this.allGrpLocations) {
                    if (locationId == element2.Id && element2.Provider_Company__c == selectedGrpID) {
                        this.providerTypeOptions.push({
                            label: element.Name,
                            value: element.Id
                        });
                    }

                }


            }
        }

    }

    filterProviderUsingGTypeAndCareCat(selectedGrpID, selectedCareCatID) {
        //    = this.allGroups.find(({ Id }) => Id === selectedGrpID);

        for (const element of this.allProviders) {
            if (element.Provider_Company__c == selectedGrpID && element.Resource_Category__c == selectedCareCatID) {
                this.providerOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }

    }


    filterCareCat(affId) {
        // console.log(affId);
        // console.log(this.allGroups.size());
        for (const element of this.allGroups) {
            // console.log('hii');
            // console.log('huu'+element.Id);
            // console.log('ii');
            if (element.Id == affId) {
                // console.log('uuu' +element.Resource_Category__c);
                this.selectedCareCatID = element.Resource_Category__c;
                // console.log('oop  '+ this.selectedCareCatID);
                // console.log(element.Resource_Category__c);
                this.appointment.Resource_Category__c = element.Resource_Category__c;
                this.filterAppTypes(this.selectedCareCatID);
                this.filterGroupLocations(this.selectedGrpID);
                this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID, this.selectedgrpLocationID)
                this.filterProviderUsingCCat(this.selectedAppTypeID, this.selectedProviderTypeID, this.selectedgrpLocationID);

                //0 this.filterAppTypes(element.Resource_Category__c);
                //0 this.filterGroups(element.Resource_Category__c);
                //0 this.filterProviderTypes(element.Resource_Category__c);
                //0 this.filterProviers(element.Resource_Category__c);
                //0 this.checkStartDateEnable(element.Resource_Category__c);

            }
        }



        // this.appointment.Resource_Category__c = affId;

    }

    handleGroLocationChange(event) {
        //
        this.selectedgrpLocationID = event.detail.value;
        this.appointment.Clinic_Location__c = event.detail.value;


        // console.log('1');

        let selectedLocationObj = null;
        for (const element of this.allGrpLocations) {
            if (element.Id == event.detail.value) {
                selectedLocationObj = element;
                break;
            }
        }
        this.groupAddress = selectedLocationObj.Address_Text__c;
        for (const element of this.allGroups) {
            if (element.Id == selectedLocationObj.Provider_Company__c) {
                // element.Clinic_Location__c = selectedLocationObj.Clinic_Location__c;
                this.selectedGrpID = element.Id;
              //   this.selectedCareCat = element.Address_Text__c;
                break;
            }
        }

        this.filterCareCatFromLocation(this.selectedgrpLocationID);
        this.filterProviers(this.selectedCareCatID,this.providerTypeID,this.selectedgrpLocationID);



     //   this.selectedCareCatID = element.Resource_Category__c;
        // console.log('i m success');
     

   

        // this.filterGroupLocations(this.selectedGrpID);
     //   this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID, this.selectedgrpLocationID)//p 
       // this.filterProviderUsingCCat(this.selectedAppTypeID, this.selectedProviderTypeID, this.selectedgrpLocationID);//p
        //0 this.filterAppTypes(element.Resource_Category__c);
        //0 this.filterGroups(element.Resource_Category__c);
        //0 this.filterProviderTypes(element.Resource_Category__c);
        //0 this.filterProviers(element.Resource_Category__c);


























        // console.log('2');



        /*0 if (this.selectedGrpID != selectedLocationObj.Provider_Company__c || this.selectedGrpID == null) {
            this.filterGroupByLocation(selectedLocationObj.Provider_Company__c);
        }

        this.filterProviers();
        // this.filterProviderTypes();
        this.filterPTypeUsingCareCAndGLocation(this.selectedgrpLocationID, this.selectedCareCatID);
        this.filterProviderUsingCCatAndLocation(this.selectedgrpLocationID, this.selectedCareCatID);*/



        if (this.selectedDate != '') {
            this.getProviders(this.startTime);
        };
        this.checkStartDateEnable();

    }


    filterPTypeUsingCareCAndGLocation(locationId, careCatId) {

        for (const element of this.allProviderTypes) {
            if (element.Clinic_Location__c == locationId && element.Resource_Category__c == careCatId) {
                this.providerTypeOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }

    }
    
    filterCareCatFromLocation(locationId){
        
        receiveCareCategoriesOfClinic({ locationId: locationId })
        .then(result => {


           console.log('hiii '+result.length);
            this.careCategoryList = result; // Store the result
           // this.error = undefined; // Clear any previous errors
             this.allCareCategories = [];
            this.allCareCategories = result.map(careCat => ({
                label: careCat.Name, // Display Name as label
                value: careCat.Id // Use Id as value
            }));


            if(this.allCareCategories.length>0){
                if( this.selectedCareCatID == ''){
                  //  this.selectedCareCatID = this.allCareCategories[0].value;
                    
                }
              // this.filterAppTypes(this.selectedCareCatID);  //p 
              if(this.selectedCareCatID == ''){
                this.filterAllAppTypes(this.allCareCategories);
              } else{
                this.filterAppTypes(this.selectedCareCatID);
              }
            }else{

              

            }
      
     
    //  //    this.value = ' gggggggggggggggggggggggggggggggg';
    //         if (this.allCareCategories.length > 0) {
    //         //     this.selectedCareCatID = this.allCareCategories[0].value;
     
    //         //  this.selectedAppTypeID = 'a3OWr000001R1sHMAS';
    //          // this.filterAppTypes(this.selectedCareCatID);  //p 
    //         }else{

    //             this.allCareCategories =  [{
    //                 label: 'No Care Category Available', // Display Name as label
    //                 value: '.' // Empty value
    //             }];
    //             this.selectedCareCatID = this.allCareCategories[0].value;
                  
     
    //         }
        })
        .catch(error => {
            // this.allCareCategories =  [{
            //     label: 'No ', // Display Name as label
            //     value: '.' // Empty value
            // }];
          //  this.selectedCareCatID = this.careCategoryList[0].value;
         //   this.error = error.body.message; // Capture and display the error message
           // this.careCategoryList = []; // Clear the list in case of error
        });

    }



    filterProviderUsingCCatAndLocation(locationId, careCatId) {
        for (const element of this.allProviders) {
            if (element.Clinic_Location__c == locationId && element.Resource_Category__c == careCatId) {
                this.providerOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            }
        }

    }
    handleProviderTypeChange(event) {
        // console.log('handleProviderTypeChange-->', event.detail.value);
        this.selectedProviderTypeID = event.detail.value;

        this.appointment.Resource_Type__c = event.detail.value;

        for (const element of this.allProviderTypes) {
            if (element.Id == event.detail.value) {
                // this.appointment.Appointment_Type__c = element.Appointment_Type__c;
                // this.selectedAppTypeID = element.Appointment_Type__c;
                // console.log('i m location ID : ' + element.Clinic_Location__c);
               // this.selectedgrpLocationID = element.Clinic_Location__c;
              //  this.appointment.Clinic_Location__c = element.Clinic_Location__c;
              //  const targetId =  this.allGrpLocations.find(group => group.Id === this.selectedgrpLocationID);
               
            //    const matchingGroup = this.allGroups.find(group => group.Id === targetId.Provider_Company__c);

                 // this.selectedGrpID = matchingGroup.Id;
                //  this.appointment.Provider_Company__c = matchingGroup.Id;

                this.selectedCareCatID = element.Resource_Category__c;
                // console.log('Care Category in ProviderType: ', this.selectedCareCatID);
              //  this.selectedAppTypeID = element.Appointment_Type__c;

               // const selectedAppType = this.allAppTypes.find(({ Id }) => Id === this.selectedAppTypeID);

               // this.selectedDuration = selectedAppType.Duration__c;
            //    if(this.selectedCareCatID == '' && this.selectedgrpLocationID == ''){
            //     this.filterCareCatFromLocation(this.selectedgrpLocationID);
            //    }
    
                this.filterProviers();

                // this.filterAppTypes(this.selectedCareCatID);
            //    this.filterGroups(this.selectedCareCatID, 1);p 
                // this.filterGroupLocations(this.selectedGrpID);
                // this.filterProviderTypeUCCatAndAppType(this.selectedCareCatID, this.selectedAppTypeID, this.selectedgrpLocationID)
                //this.filterProviderUsingCCat(this.selectedAppTypeID, this.selectedProviderTypeID, this.selectedgrpLocationID);p

                /*this.filterGroupLocations(this.selectedGrpID);

                 this.selectedAppTypeID = element.Appointment_Type__c;
                this.appointment.Appointment_Type__c = element.Appointment_Type__c;
                this.selectedCareCatID = element.Resource_Category__c;

                this.filterGroups(element.Resource_Category__c);
                this.filterAppTypes(element.Resource_Category__c);
                this.filterProviderTypes();
                this.filterProviers();*/


                // this.selectedGrpID = element.Provider_Company__c;
              //  this.groupAddress = element.Clinic_Location__r.Address_Text__c;

            }
        }


        // this.filterProviderTypes();
        // this.filterProviers();
        if (this.selectedDate != '') {
            this.getProviders(this.startTime);
        };
        this.checkStartDateEnable();
    }

    handleProviderChange(event) {
        this.appointment.Clinic_Resource__c = event.detail.value;
        this.selectedProvider = event.detail.value;


        for (const element of this.allProviders) {
            if (element.Id == event.detail.value) {
                this.appointment.Resource_Category__c = element.Resource_Category__c;

                this.selectedCareCatID = element.Resource_Type__r.Resource_Category__c;
                


                this.selectedGrpID = element.Clinic_Location__r.Provider_Company__c;


                //this.selectedAppTypeID = element.Appointment_Type__c;

               // const selectedAppType = this.allAppTypes.find(({ Id }) => Id === this.selectedAppTypeID);

              //  this.selectedDuration = selectedAppType.Duration__c;
              //  this.duration = selectedAppType.Duration__c.split(' ')[0];
                if (this.startTime && this.selectedAppTypeID) {
                    this.endTime = this.calculateEndTime(this.startTime, this.duration);
                    this.appointment.End_Time__c = this.endTime;
                }
                this.selectedgrpLocationID = element.Clinic_Location__c;
                this.filterCareCatFromLocation( this.selectedgrpLocationID);



                this.selectedProviderTypeID = element.Resource_Type__c;
                //console.log('selected Group Location of element-->', element);

                this.groupAddress = element.Clinic_Location__r.Address_Text__c;
                // console.log('Passed value to find group locations-->', this.selectedgrpLocationID, 'category Id: ', this.selectedCareCatID, 'AppTypeID: ', this.selectedAppTypeID);

                if (this.providerTypeOptions.length < 1) {
                  
                    this.selectedProviderTypeID = '';
                } else {
                    console.log('hlw');
                    this.providerTypeOptions = this.providerTypeOptions.filter(option => option.value !== '');

                    this.selectedProviderTypeID = element.Resource_Type__c;
                }



                // this.filterProviderTypes();
                // this.filterProviers();

                //         this.selectedAppTypeID = element.Appointment_Type__c;





                //         this.selectedAppTypeID =element.Appointment_Type__c ;
                //         this.appointment.Appointment_Type__c = element.Appointment_Type__c;

                //         const selectedAppType = this.allAppTypes.find(({ Id }) => Id === element.Appointment_Type__c);

                //         this.selectedDuration = selectedAppType.Duration__c;
                //         this.duration = selectedAppType.Duration__c.split(' ')[0];

                //         if (this.startTime && this.selectedAppTypeID) {
                //             console.log('hii '+this.startTime +this.duration);
                //             this.endTime = this.calculateEndTime(this.startTime, this.duration);
                //             console.log('kkk '+ this.endTime );
                //             this.appointment.End_Time__c = this.endTime;
                //             console.log( this.appointment.End_Time__c);
                //             // this.isEndTimeDisabled = true;
                //         }

                //         this.filterProviderTypes();
                //         this.filterProviers();

                //         this.selectedProvider = event.detail.value;
                //         this.selectedAppTypeID =element.Appointment_Type__c ;

                // console.log( this.selectedProvider  +'oioioi'+this.selectedAppTypeID)
            }
            // this.filterProviers();

        }



        // console.log('handleProviderChange-->', event.detail.value);
        // this.selectedProviderTypeID  = event.detail.value;
        // this.filterProviderTypes();
        // this.filterProviers();
        this.checkStartDateEnable();
    }

    isEndTimeDisabled = true;

    handleStartTimeChange(event) {
        console.log('start time change');
        const startTime = event.target.value; // Start time in HH:mm format
        const startTimeInput = this.template.querySelector('.startTimeInAppointment');
        // console.log('isStartTimeInvalid --> ', this.isStartTimeInvalid);
        if (!startTimeInput) {

            console.error('Start Time input field not found!');
            return;
        }
        if (this.isStartTimeInvalid) {
            startTimeInput.setCustomValidity('Start Time cannot be selected for previous dates.');
        } else {
            startTimeInput.setCustomValidity(''); // Clear error
        }
        startTimeInput.reportValidity();
        this.selectedTime = startTime;
        this.startTime = startTime;

        // console.log('startTime-->', startTime);
        this.appointment.Start_Time__c = event.detail.value;
        // console.log(startTime + 'uuuuuuuuuuuuu   ' + this.duration);

        if (startTime && this.selectedAppTypeID) {
            // console.log('hii ' + startTime + this.duration);
            this.endTime = this.calculateEndTime(startTime, this.duration);
            // console.log('kkk ' + this.endTime);
            this.appointment.End_Time__c = this.endTime;
            // console.log(this.appointment.End_Time__c);
            // this.isEndTimeDisabled = true;
        }
        this.getProviders(this.startTime);
    }

    // getProviders(tim) {
    //     // console.log(typeof(this.selectedDate)+'   i m date'+ this.selectedDate+ ' ii'+tim);
    //     if (this.selectedProvider) {
    //         tim = '';
    //     }
    //     getProvidersTimeFiltered({ dateT: this.selectedDate, timee: tim }).then(results => {
    //         // console.log('results -->', results);


    //         const sourceProviders = [...this.allProviders];
    //         // console.log('Provider type Options: ', this.providerTypeOptions);
    //         this.providerOptions = [];
    //         for (const provider of sourceProviders) {
    //             Object.entries(results).forEach(([key, value]) => {
    //                 if (key === provider.Id && value.Resource_Type__c === this.selectedProviderTypeID
    //                     && value.Appointment_Type__c === this.selectedAppTypeID && value.Clinic_Location__c === this.selectedgrpLocationID
    //                     && this.selectedProviderTypeID !== '') {
    //                     // console.log('In Option 1');
    //                     this.providerOptions.push({
    //                         label: provider.Name || provider.label,
    //                         value: provider.Id
    //                     });
    //                 } else if (key === provider.Id && value.Appointment_Type__c === this.selectedAppTypeID &&
    //                     value.Clinic_Location__c === this.selectedgrpLocationID && this.selectedProviderTypeID === '') {
    //                     // console.log('In Option 2');
    //                     this.providerOptions.push({
    //                         label: provider.Name || provider.label,
    //                         value: provider.Id
    //                     });
    //                 } else if (key === provider.Id && value.Appointment_Type__c === this.selectedAppTypeID && this.selectedgrpLocationID === ''
    //                     && this.selectedProviderTypeID === '') {
    //                     // console.log('In Option 3');
    //                     this.providerOptions.push({
    //                         label: provider.Name || provider.label,
    //                         value: provider.Id
    //                     });
    //                 } else if (key === provider.Id && this.selectedAppTypeID === '' && this.selectedgrpLocationID === ''
    //                     && this.selectedProviderTypeID === '' && this.selectedCareCatID !== '') {
    //                     // console.log('In Option 4');
    //                     for (const providerType of this.providerTypeOptions) {
    //                         if (providerType.value === value.Resource_Type__c) {
    //                             this.providerOptions.push({
    //                                 label: provider.Name || provider.label,
    //                                 value: provider.Id
    //                             });
    //                         }
    //                     }
    //                 }
    //                 else if (key === provider.Id && this.selectedProviderTypeID === '' && this.selectedAppTypeID === '' && this.selectedgrpLocationID === '' && this.selectedCareCatID === '') {
    //                     // console.log('In Option 5');
    //                     this.providerOptions.push({
    //                         label: provider.Name || provider.label,
    //                         value: provider.Id
    //                     });
    //                 }
    //             });
    //         }

    //         // Handle case where no providers are available
    //         if (this.providerOptions.length < 1) {
    //             this.providerOptions = [
    //                 {
    //                     label: 'No Provider Available',
    //                     value: ''
    //                 }
    //             ];
    //             this.startTime = '';
    //             this.endTime = '';
    //             this.startTimeOptions =[];
    //         }
    //         console.log('start tiime'+ this.startTimeOptions);
    //         if (this.startTimeOptions && this.startTimeOptions.length > 0 ) {
    //             console.log("if condition")
    //             this.isStartDateDisabled = false;
    //         }else{
    //             this.isStartDateDisabled = true;
    //             console.log("else condition")
    //         }

    //         // Optionally set the first available provider as the selected one
    //         // this.selectedProvider = this.providerOptions[0]?.value || '';
    //         const selectedProviderExists = this.providerOptions.some(
    //             option => option.value === this.selectedProvider
    //         );

    //         if (selectedProviderExists) {
    //             // Optionally set the first available provider as the selected one
    //             // this.selectedProvider = this.providerOptions[0].value;
    //         } else {
    //             this.selectedProvider = '';
    //         }
    //         //   for(const element of results){
    //         //       this.providerOptions.push({label: element.Name, value: element.Id});
    //         //   }
    //         //   this.providerOptions = results.map(item => ({
    //         //     label: item.Name,
    //         //     value: item.Id
    //         // }));
    //         //   this.providerOptions.push({
    //         //     label: element.Name,
    //         //     value:element.Id
    //         // });


    //         //   this.providerOptions
    //     }).catch(error => {
    //         // console.log('err');
    //         console.error('Error on fetchAllCareCategories:', error);
    //     });


    // }
    getProviders(tim) {
        // Log to check the values of `selectedDate`, `selectedProvider`, and `tim`
        console.log('selectedDate:', this.selectedDate);
        console.log('selectedProvider:', this.selectedProvider);
        console.log('tim:', tim);
    
        if (this.selectedProvider) {
            tim = '';
        }
    
        getProvidersTimeFiltered({ dateT: this.selectedDate, timee: tim }).then(results => {
            // Log the results fetched
            console.log('Fetched results:', results);
    
            const sourceProviders = [...this.allProviders];
           // console.log('All providers:', sourceProviders);
    
            this.providerOptions = [];
    
            for (const provider of sourceProviders) {
                Object.entries(results).forEach(([key, value]) => {
                    // Log the current provider and the results key/value pair
                   // console.log('Checking provider:', provider.Name, 'with result key:', key, 'and value:', value);
    
                    if (key === provider.Id && value.Resource_Type__c === this.selectedProviderTypeID
                        && value.Appointment_Type__c === this.selectedAppTypeID && value.Clinic_Location__c === this.selectedgrpLocationID
                        && this.selectedProviderTypeID !== '') {
                        console.log('In Option 1');
                        this.providerOptions.push({
                            label: provider.Name || provider.label,
                            value: provider.Id
                        });   
                        console.log('Updated providerOptions:', JSON.stringify(this.providerOptions));
                    } else if (key === provider.Id && value.Appointment_Type__c === this.selectedAppTypeID &&
                        value.Clinic_Location__c === this.selectedgrpLocationID && this.selectedProviderTypeID === '') {
                        console.log('In Option 2');
                        this.providerOptions.push({
                            label: provider.Name || provider.label,
                            value: provider.Id
                        });
                    } else if (key === provider.Id && value.Appointment_Type__c === this.selectedAppTypeID && this.selectedgrpLocationID === ''
                        && this.selectedProviderTypeID === '') {
                        console.log('In Option 3');
                        this.providerOptions.push({
                            label: provider.Name || provider.label,
                            value: provider.Id
                        });
                    } else if (key === provider.Id && this.selectedAppTypeID === '' && this.selectedgrpLocationID === ''
                        && this.selectedProviderTypeID === '' && this.selectedCareCatID !== '') {
                        console.log('In Option 4');
                        for (const providerType of this.providerTypeOptions) {
                            if (providerType.value === value.Resource_Type__c) {
                                this.providerOptions.push({
                                    label: provider.Name || provider.label,
                                    value: provider.Id
                                });
                            }
                        }
                    } else if (key === provider.Id && this.selectedProviderTypeID === '' && this.selectedAppTypeID === '' && this.selectedgrpLocationID === '' && this.selectedCareCatID === '') {
                        console.log('In Option 5');
                        this.providerOptions.push({
                            label: provider.Name || provider.label,
                            value: provider.Id
                        });
                    }
                });
            }
    
            // Log the providerOptions after population
            console.log('Provider Options after population:', this.providerOptions);

    
            // Handle case where no providers are available
            if (this.providerOptions.length < 1) {
                console.log('hlw');
                this.providerOptions = [
                    {
                        label: 'No Provider Available',
                        value: ''
                    }
                ];
                this.startTime = '';
                this.endTime = '';
                this.startTimeOptions = [];
                this.isStartTimeDisabled= true;
            }
    
            // Log the startTimeOptions
            console.log('startTimeOptions:', JSON.stringify(this.startTimeOptions));
    
            // Check if startTimeOptions has items
            if (this.startTimeOptions && this.startTimeOptions.length > 0) {
                console.log(this.startTimeOptions);
                console.log('StartTimeOptions is not empty');
                this.isStartDateDisabled = false;
            } else {
                console.log('StartTimeOptions is empty');
                this.isStartDateDisabled = true;
            }
    
            // Optionally set the first available provider as the selected one
            const selectedProviderExists = this.providerOptions.some(
                option => option.value === this.selectedProvider
            );
    
            if (selectedProviderExists) {
                console.log('Selected provider exists:', this.selectedProvider);
            } else {
                console.log('Selected provider does not exist, resetting selectedProvider');
                this.selectedProvider = '';
            }
        }).catch(error => {
            console.error('Error in getProviders:', error);
        });
    }
    
    getProvidersUnavailable(tim) {

        getProvidersTimeFiltered({ dateT: this.selectedDateU, timee: tim }).then(results => {
            // console.log('results -->', results);
            const sourceProviders = [...this.allProviders];
            // Clear providerOptions before refilling
            this.providerOptionsUnavailable = [];
            // Filter providers based on the results map
            
            for (const provider of sourceProviders) {
                // Iterate over the entries in the results map
                Object.entries(results).forEach(([key, value]) => {
                    if (key === provider.Id && value.Resource_Type__c === this.selectedProviderTypeU
                        && value.Clinic_Location__c === this.selectedGrpLocationU
                        && this.selectedProviderTypeU !== '') {
                            console.log('in if condition')
                        this.providerOptionsUnavailable.push({
                            label: provider.Name || provider.label,
                            value: provider.Id
                        });
                    }
                    else if (key === provider.Id && this.selectedProviderTypeU != '' && this.selectedGrpLocationU != '' && this.selectedGroupU != '') {
                        console.log('selected provider type: ', this.selectedProviderTypeU);
                        console.log('in else if condition')
                        this.providerOptionsUnavailable.push({
                            label: provider.Name || provider.label,
                            value: provider.Id
                        });
                    }
                    
                });
            }
            // Handle case where no providers are available
            if (this.providerOptionsUnavailable.length < 1) {
                this.providerOptionsUnavailable = [
                    {
                        label: 'No Provider Available',
                        value: ''
                    }
                ];
            }
            const isSelectedProviderAvailable = this.providerOptionsUnavailable.some(
                option => option.value === this.selectedProviderU
            );
            
            // Only clear selectedProviderU if it is not in the list of unavailable providers
            if (!isSelectedProviderAvailable) {
                this.selectedProviderU = '';
            }
        }).catch(error => {
            console.log('err');
            console.error('Error on fetchAllCareCategories:', error);
        });
    }
    addMinutes(time, minutes) {
        let [hours, mins] = time.split(':').map(Number);
        mins += minutes;
        if (mins >= 60) {
            mins -= 60;
            hours += 1;
        }
        if (hours >= 24) {
            hours -= 24;
        }
        return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
    }
    timeToMinutes(time) {
        const [hours, minutes] = time.split(':').map(Number);
        return hours * 60 + minutes;
    }
    
    // Function to filter end times based on start time
    getEndTimeOptions(startTime) {
        const startMinutes = this.timeToMinutes(startTime);
    
        const filteredOptions = [];
        const tempEndTimeOptions = this.startTimeOptions.map(option => {
            const newTime = this.addMinutes(option.value, 15);
            return {
                label: `${newTime} ${option.label.includes('AM') ? 'AM' : 'PM'}`, // Preserve AM/PM format
                value: newTime
            };
        });
        let lastOptionMinutes = startMinutes;
    
        // Iterate through sorted options
        for (const option of tempEndTimeOptions) {
            const optionMinutes = this.timeToMinutes(option.value);
    
            // Include times that are after the start time and are within a continuous sequence
            if (optionMinutes > startMinutes) {
                if (optionMinutes - lastOptionMinutes > 15) {
                    // Break if there is a gap greater than 15 minutes
                    break;
                }
                filteredOptions.push({
                    label: option.label,
                    value: option.value
                });
                lastOptionMinutes = optionMinutes;
            }
        }
    
        return filteredOptions;
    }
    


    handleStartTimeChangeU(event) {
        const startTime = event.target.value; // Start time in HH:mm format

        this.startTimeU = startTime;
        this.appointment.Start_Time__c = event.detail.value;
        this.isEndTimeDisabled = !this.startTimeU;
        // console.log('startTimeU-->', this.startTimeU);
        // console.log('endTimeU-->', this.endTimeU);
        this.endTimeOptions = this.getEndTimeOptions(this.startTimeU);

        if (this.startTimeU && this.endTimeU) {
            // If both values exist, call the calculateDuration function
            // this.calculateDurationInMinutes(this.startTimeU, this.endTimeU);
        }


    }
    handleEndTimeChangeU(event) {
        const endTimeu = event.target.value;
        this.appointment.End_Time__c = endTimeu;
        this.endTimeU = endTimeu;
        if (this.startTimeU && this.endTimeU && this.endTimeU <= this.startTimeU) {
            this.timeErrorMessage = 'End Time must be greater than Start Time.';
        } else {
            this.timeErrorMessage = '';
            this.calculateDurationInMinutes(this.startTimeU, this.endTimeU)
        }
    }

    handleNotesChange(event) {
        this.appointment.Description__c = event.detail.value;
    }

    filterProviderTypeULocation(locationId, careCatId, AppTypeId) {
        this.providerTypeOptions = [];

        // console.log('kit');
        // console.log(locationId);
        for (const element of this.allProviderTypes) {
            // console.log(element.Clinic_Location__c);
            if (locationId == element.Clinic_Location__c && element.Resource_Category__c == careCatId) {
                // console.log('chj');
                this.providerTypeOptions.push({
                    label: element.Name,
                    value: element.Id
                });


            }
        }
        if (this.providerTypeOptions.length < 1) {
            this.providerTypeOptions = [{
                label: 'No Provider Available',
                value: ''
            }];

            this.selectedProviderTypeID = '';
        }
        // console.log('ProviderTypeOptions: ', JSON.stringify(this.providerTypeOptions));
    }
    addMinutes(time, minutes) {
        let [hours, mins] = time.split(':').map(Number);
        mins += minutes;
        if (mins >= 60) {
            mins -= 60;
            hours += 1;
        }
        if (hours >= 24) {
            hours -= 24;
        }
        return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
    }
    async checkStartDateEnable() {
        console.log('hummmmm nilufa');
    
        // Check if selected date is set
        if (this.selectedDateU != '') {
            this.isStartDateDisabled = true;
        }
    
        let temp = '';
    
        // If appointment date is not set
        if (this.appointment.Appointed_Date__c == null) {
            const result = [
                '12:00 AM', '12:15 AM', '12:30 AM', '12:45 AM',
                '01:00 AM', '01:15 AM', '01:30 AM', '01:45 AM',
                '02:00 AM', '02:15 AM', '02:30 AM', '02:45 AM',
                '03:00 AM', '03:15 AM', '03:30 AM', '03:45 AM',
                '04:00 AM', '04:15 AM', '04:30 AM', '04:45 AM',
                '05:00 AM', '05:15 AM', '05:30 AM', '05:45 AM',
                '06:00 AM', '06:15 AM', '06:30 AM', '06:45 AM',
                '07:00 AM', '07:15 AM', '07:30 AM', '07:45 AM',
                '08:00 AM', '08:15 AM', '08:30 AM', '08:45 AM',
                '09:00 AM', '09:15 AM', '09:30 AM', '09:45 AM',
                '10:00 AM', '10:15 AM', '10:30 AM', '10:45 AM',
                '11:00 AM', '11:15 AM', '11:30 AM', '11:45 AM',
                '12:00 PM', '12:15 PM', '12:30 PM', '12:45 PM',
                '01:00 PM', '01:15 PM', '01:30 PM', '01:45 PM',
                '02:00 PM', '02:15 PM', '02:30 PM', '02:45 PM',
                '03:00 PM', '03:15 PM', '03:30 PM', '03:45 PM',
                '04:00 PM', '04:15 PM', '04:30 PM', '04:45 PM',
                '05:00 PM', '05:15 PM', '05:30 PM', '05:45 PM',
                '06:00 PM', '06:15 PM', '06:30 PM', '06:45 PM',
                '07:00 PM', '07:15 PM', '07:30 PM', '07:45 PM',
                '08:00 PM', '08:15 PM', '08:30 PM', '08:45 PM',
                '09:00 PM', '09:15 PM', '09:30 PM', '09:45 PM',
                '10:00 PM', '10:15 PM', '10:30 PM', '10:45 PM',
                '11:00 PM', '11:15 PM', '11:30 PM', '11:45 PM'
            ];
    
            this.startTimeOptions = result.map(item => ({
                label: item,  // Display text
                value: item   // Actual value used in selection
            }));
        } else {
            // Initialize variables based on selected values
            let providertype = this.selectedProviderTypeID || '';
            let appduration = this.selectedDuration || '';
            let locationid = this.selectedgrpLocationID || '';
            let carecategoryid = this.selectedCareCatID || '';
            let appointmentdate = this.appointment.Appointed_Date__c || '';
            
            if (this.isUnavailable) {
                providertype = this.selectedProviderTypeU;
                appduration = this.selectedDurationU;
                locationid = this.selectedGrpLocationU;
                carecategoryid = this.selectedCareCatU;
                appointmentdate = this.selectedDateU;
                temp = this.selectedProviderU;
            } else {
                providertype = this.selectedProviderTypeID;
                appduration = this.selectedDuration;
                locationid = this.selectedgrpLocationID;
                carecategoryid = this.selectedCareCatID;
                appointmentdate = this.appointment.Appointed_Date__c;
                temp = this.selectedProvider;
            }
    
            console.log('Provider Type: ', providertype);
            console.log('Duration: ', appduration);
            console.log('Location: ', locationid);
            console.log('Care Category: ', carecategoryid);
            console.log('Appointment Date: ', appointmentdate);
            console.log('Temp value: ', temp);
    
            // Call the asynchronous function to fetch appointment times
            await this.fetchAppointments({
                providerTypeID: providertype,
                appDuration: appduration,
                locationID: locationid,
                careCategoryID: carecategoryid,
                appointmentDate: appointmentdate,
                doc: temp
            });
        }
    }
    
    async fetchAppointments({ providerTypeID, appDuration, locationID, careCategoryID, appointmentDate, doc }) {
        try {
            // Assume getAppointments fetches data from an API
            const result = await  getAppointments({
                providerTypeID,
                appDuration,
                locationID,
                careCategoryID,
                appointmentDate,
                doc
            });
    
            console.log('Result from getAppointments:', JSON.stringify(result));
    
            const currentDate = new Date();
            const currentTime = currentDate.getHours() * 60 + currentDate.getMinutes();
    
            this.startTimeOptions = result
                .filter(item => {
                    const [hours, minutes] = item.split(':').map(Number);
                    const itemTimeInMinutes = hours * 60 + minutes;
    
                    // If appointment date is today, filter out past times
                    if (appointmentDate === currentDate.toISOString().split('T')[0]) {
                        return itemTimeInMinutes >= currentTime;
                    }
    
                    return true;
                })
                .map(item => {
                    let [hours, minutes] = item.split(':').map(Number);
                    const period = hours >= 12 ? 'PM' : 'AM';
                    hours = hours % 12 || 12;
                    const label = `${hours}:${minutes.toString().padStart(2, '0')} ${period}`;
    
                    return {
                        label: label, // Display text in 12-hour format
                        value: item   // Original value in 24-hour format
                    };
                });
    
            console.log('Updated startTimeOptions:', JSON.stringify(this.startTimeOptions));
        } catch (error) {
            console.error('Error fetching appointments:', error);
        }
    }
    

    calculateEndTime(startTime, durationInMinutes) {
        // Parse the start time
        var r = startTime.split(' ')[0];

        const [hours, minutes] = r.split(':').map(Number);
        const startDate = new Date();
        startDate.setHours(hours, minutes);
        // console.log('haha'+startDate);

        // Add the duration
        const endDate = new Date(startDate.getTime() + durationInMinutes * 60000);
        // console.log('haha'+endDate);

        // Format the end time back to HH:mm
        const endHours = String(endDate.getHours()).padStart(2, '0');
        const endMinutes = String(endDate.getMinutes()).padStart(2, '0');
        // console.log('haha'+endHours +' '+endMinutes);
        return `${endHours}:${endMinutes}`;
    }


    async createNewAppointment(event) {
        event.preventDefault();
        this.errorMessage = null;
        console.log('this.selectedRecordTypeValue 1' + this.selectedRecordTypeValue);



        if(this.selectedRecordTypeValue =='Unavailable' ){
            console.log('in unavailable');
            console.log('selected date:', this.selectedDateU)
            console.log('start time:', this.startTimeU)
            console.log('end time:', this.endTimeU)
            console.log('duration:', this.durationInMinutesU)
            console.log('selected provider:', this.selectedProviderU)
            console.log('selected care cat:', this.selectedCareCatU)
            
      if( this.selectedDateU != null && this.startTimeU != null && this.endTimeU != null && this.durationInMinutesU != null && this.selectedCareCatU != null){

        this.spinner = true;
    
        this.appointment.event_Type = this.selectedRecordTypeValue;
        this.appointment.Provider_Company__c = this.selectedGroupU;
        this.appointment.Resource_Category__c = this.selectedCareCatU;
        // this.appointment.Appointment_Type__c = this.selectedAppTypeID;
        this.appointment.Clinic_Location__c = this.selectedGrpLocationU;

            this.appointment.Telehealth__c = 'No';
     

        // this.appointment.Clinic_Resource__c = this.selectedProviderU;
        this.appointment.Resource_Type__c = this.selectedProviderTypeU;
        // this.appointment.Room_Type__c = 'One Gen Room';
          console.log(' i m unavailable');
        // console.log('Appointment:' + JSON.stringify(this.appointment));
        await sendAppointment({ jsonData: JSON.stringify(this.appointment) }).then(res => {
            // console.log('sendAppointment-->', res);
            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'Appointment has been created successfully.',
                variant: 'success',
            });
            this.dispatchEvent(toastEvent);
            console.log('hlwwww from toast');

        }).catch(error => {
            console.error('Error on sendAppointment:', error);
            // console.log(res);
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
            this.errorMessage = error.body.message;
            this.spinner = false;

          

        });
        if (this.errorMessage == null ) {
            if(this.accountID==''){
            
            this.callParent();
            }
            else{
              
                this.spinner = false;
                this.form = false;
                this.closeBtnOnClick();
                
            }
        } else {
            this.spinner = false;
        }
    }
   




        }else{
            console.log('this.selectedRecordTypeValue 2' + this.selectedRecordTypeValue);
            const allComboboxes = this.template.querySelectorAll('lightning-combobox');
            const inputs = this.template.querySelectorAll('lightning-input');
            const patients = this.template.querySelectorAll('lightning-record-picker');
    
            // Validate all comboboxes
            let isValid = true;
            allComboboxes.forEach(combobox => {
                if (!combobox.reportValidity()) {
                    isValid = false;
                }
            });
    
            inputs.forEach(input => {
                if (!input.reportValidity()) {
                    isValid = false;
                }
            });
    
            patients.forEach(patient => {
                if (!patient.reportValidity()) {
                    isValid = false;
                }
            });
    
            if (isValid) {
                this.spinner = true;
    
                this.appointment.event_Type = this.selectedRecordTypeValue;
                this.appointment.Provider_Company__c = this.selectedGrpID;
                this.appointment.Resource_Category__c = this.selectedCareCatID;
                this.appointment.Appointment_Type__c = this.selectedAppTypeID;
                this.appointment.Clinic_Location__c = this.selectedgrpLocationID;
    
                if (this.isTelehealth) {
                    this.appointment.Telehealth__c = 'Yes';
                } else {
                    this.appointment.Telehealth__c = 'No';
                }
    
                this.appointment.Clinic_Resource__c = this.selectedProvider;
                this.appointment.Resource_Type__c = this.selectedProviderTypeID;
                this.appointment.Room_Type__c = 'One Gen Room';
    
                // console.log('Appointment:' + JSON.stringify(this.appointment));
                await sendAppointment({ jsonData: JSON.stringify(this.appointment) }).then(res => {
                    // console.log('sendAppointment-->', res);
                    const toastEvent = new ShowToastEvent({
                        title: 'Success',
                        message: 'Appointment has been created successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(toastEvent);
    
                }).catch(error => {
                    console.error('Error on sendAppointment:', error);
                    // console.log(res);
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvent);
                    this.errorMessage = error.body.message;
                    this.spinner = false;
    
                });
                if (this.errorMessage == null) {
                    
                console.log('acc id-->'+this.accountID);
                    if(this.accountID== ''){
                    console.log('hlw2');
                    this.callParent();
                    }
                    else{
                        console.log('hlw 3');
                        this.spinner = false;
                        this.form = false;
                        this.closeBtnOnClick();
                     
                    }
                  
                } else {
                    this.spinner = false;
                }
            }
             else {
          //  Proceed only if all comboboxes are valid
                console.log('Some comboboxes are invalid. Please fix errors.');
            }
    

        }

      
    }

    callParent() {
        let paramData = 'Data';
        let event = new CustomEvent('appointmentsave', { detail: paramData });
        this.dispatchEvent(event);
    }

}





const timeZones = [
    // North America
    { abbreviation: "PST", fullName: "Pacific Standard Time" },
    { abbreviation: "PDT", fullName: "Pacific Daylight Time" },
    { abbreviation: "MST", fullName: "Mountain Standard Time" },
    { abbreviation: "MDT", fullName: "Mountain Daylight Time" },
    { abbreviation: "CST", fullName: "Central Standard Time" },
    { abbreviation: "CDT", fullName: "Central Daylight Time" },
    { abbreviation: "EST", fullName: "Eastern Standard Time" },
    { abbreviation: "EDT", fullName: "Eastern Daylight Time" },
    { abbreviation: "AST", fullName: "Atlantic Standard Time" },
    { abbreviation: "NST", fullName: "Newfoundland Standard Time" },

    // Europe
    { abbreviation: "GMT", fullName: "Greenwich Mean Time" },
    { abbreviation: "BST", fullName: "British Summer Time" },
    { abbreviation: "CET", fullName: "Central European Time" },
    { abbreviation: "CEST", fullName: "Central European Summer Time" },
    { abbreviation: "EET", fullName: "Eastern European Time" },
    { abbreviation: "EEST", fullName: "Eastern European Summer Time" },

    // Asia
    { abbreviation: "IST", fullName: "Indian Standard Time" },
    { abbreviation: "PKT", fullName: "Pakistan Standard Time" },
    { abbreviation: "BST", fullName: "Bangladesh Standard Time" },
    { abbreviation: "ICT", fullName: "Indochina Time" },
    { abbreviation: "CST", fullName: "China Standard Time" },
    { abbreviation: "JST", fullName: "Japan Standard Time" },
    { abbreviation: "KST", fullName: "Korea Standard Time" },

    // Australia and Oceania
    { abbreviation: "AEST", fullName: "Australian Eastern Standard Time" },
    { abbreviation: "AEDT", fullName: "Australian Eastern Daylight Time" },
    { abbreviation: "ACST", fullName: "Australian Central Standard Time" },
    { abbreviation: "ACDT", fullName: "Australian Central Daylight Time" },
    { abbreviation: "AWST", fullName: "Australian Western Standard Time" },
    { abbreviation: "NZST", fullName: "New Zealand Standard Time" },
    { abbreviation: "NZDT", fullName: "New Zealand Daylight Time" },

    // Africa
    { abbreviation: "WAT", fullName: "West Africa Time" },
    { abbreviation: "CAT", fullName: "Central Africa Time" },
    { abbreviation: "EAT", fullName: "East Africa Time" },

    // South America
    { abbreviation: "ART", fullName: "Argentina Time" },
    { abbreviation: "BRT", fullName: "Brasília Time" },
    { abbreviation: "CLT", fullName: "Chile Standard Time" },
    { abbreviation: "CLST", fullName: "Chile Summer Time" },
    { abbreviation: "PYT", fullName: "Paraguay Time" },
    { abbreviation: "UYT", fullName: "Uruguay Time" },

    // Middle East
    { abbreviation: "IRST", fullName: "Iran Standard Time" },
    { abbreviation: "AST", fullName: "Arabian Standard Time" },
    { abbreviation: "GST", fullName: "Gulf Standard Time" }
];