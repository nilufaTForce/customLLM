import { LightningElement, track, wire } from 'lwc';
import { subscribe, onError } from 'lightning/empApi';
import { getRecordCreateDefaults } from 'lightning/uiRecordApi';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendar';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import receiveAllProviders from '@salesforce/apex/CustomCalendarController.getAllProviders';
import receiveAllProviderTypes from '@salesforce/apex/CustomCalendarController.getAllProviderTypes';
import receiveAllGrpLocations from '@salesforce/apex/CustomCalendarController.getAllGrpLocations';
import receiveAllAffiliatedGrps from '@salesforce/apex/CustomCalendarController.getAllAffiliatedGrps';
import retrieveAllCompanyProviders from '@salesforce/apex/CustomCalendarController.getAllCompanyProviders';
import retrieveAllClinicLocation from '@salesforce/apex/CustomCalendarController.getClinicLocations';
import getRecordTypeNameById from '@salesforce/apex/CustomCalendarController.getRecordTypeNameById';

import retrievePatientAppointments from '@salesforce/apex/CustomCalendarController.getPatientAppointments';
// import currentUserTimeZone from '@salesforce/apex/CustomCalendarController.getCurrentUserTimeZone';
import getClosestClinicLocationId from '@salesforce/apex/DistanceService.getClosestClinicLocationId';


// import userId from '@salesforce/user/Id';
// import userTimeZone from '@salesforce/user/TimeZoneSidKey';

export default class CustomCalendar extends LightningElement {
    objectApiName = 'Appointment__c';
    @track layoutSections = [];
    @track newAppointmentModal = false;

    @track newAppModalForm = false;
    @track newRecordTypeModal = false;
    @track selectedEventInfo;

    @track activeTab = 'tab1'
    @track location = '';
    @track closestClinicId;
    @track spinner = true;
    @track ClinickNotFoundMsg = "";
    @track enabledLocation = true;
    @track optionValueLocation = "id"
    //   currentUserId = userId;
    //   userTimezone = userTimeZone;
    @track currentTimeZone;
    @track filter = false;
    gmtOffset;

    @track AppointmentTypeOptions = [
        { label: 'Appointment', value: 'Appointment' },
        { label: 'Unavailable', value: 'Unavailable' }

    ]
    channelName = '/event/AppointmentEvent__e';
    subscription = null;
    close() {
        console.log("hii");
        this.newAppointmentModal = false;

        console.log("check " + this.newAppointmentModal);
        //    window.location.reload();
    }
    handleUpdateNewModal(event) {
        this.newAppointmentModal = event.detail; // Update the value of x based on the event from the child
    }

    // @wire(currentUserTimeZone)
    // wiredUserTimeZone({ error, data }) {
    //     // console.log("hahahhahah check me " + JSON.stringify(data));
    //     if (data) {
    //         this.currentTimeZone = data.gmtOffset;
    //         // console.log(this.currentTimeZone)
    //         this.initializeCalendar();
    //     } else if (error) {
    //         console.error('Error fetching time zone:', error);
    //     }
    // }

    //   calculateGmtOffset(timeZone) {
    //     const date = new Date('2024-10-25T12:00:00'); // Fixed date for testing
    //     const options = { timeZone, timeZoneName: 'short' };
    //     const formatter = new Intl.DateTimeFormat('en-US', options);
    //     const parts = formatter.formatToParts(date);
    //     const timeZoneName = parts.find(part => part.type === 'timeZoneName').value;

    //     // Get the offset in minutes
    //     const offsetMinutes = date.getTimezoneOffset();
    //     const offsetHours = -offsetMinutes / 60; // Invert because getTimezoneOffset() gives opposite sign
    //     const gmtOffset = `GMT${offsetHours >= 0 ? '+' : ''}${offsetHours}`;

    //     return { gmtOffset, timeZoneName };
    //     }

    // wrapper = {
    //     salutaion,
    //     firstName,
    //     lastName,
    //     gender,
    //     age,
    //     appointmentDateTime,
    // };
    @wire(getRecordCreateDefaults, { objectApiName: '$objectApiName' })
    handleRecordCreateDefaults({ data, error }) {
        if (data) {
            this.layoutSections = data.layout.sections;
            this.addDateTimeFlag();
            // console.log("i m" + JSON.stringify(this.layoutSections));
        } else if (error) {
            console.error('Error fetching layout:', error);
        }
    }
    handleClinickChange(event) {

        this.closestClinicId = event.target.value

    }
    getChildStartOnClick() {
        this.strat();
    }
    strat() {
        console.log("heloooooooooooooooo");
        this.newRecordTypeModal = true;
    }


    

    openNewAppointmentModal() {
        this.ClinickNotFoundMsg = "";
        this.activeTab = 'tab1';
        this.closestClinicId = "";
        // this.newAppointmentModal = true;
        this.newRecordTypeModal = true;
    }
    closeAppointmentModal() {
        // this.newAppointmentModal = false;
        // window.location.reload();
        this.newRecordTypeModal = false;
    }

    getChildNextOnClick(event) {
        console.log("ssssssssss");
        this.nextAppointmentModal(event);
    }
    nextAppointmentModal(event) {

        console.log("ddddddddddddddddddddddddd " + event.detail);
        this.newAppointmentModal = true;
        console.log(this.newAppointmentModal);
    }

    getChildCloseDataOnClick(event) {
        this.closeAppointmentModal();
    }

    handleSaveAndNew(event) {
        event.preventDefault();
        const recordEditForm = this.template.querySelector('lightning-record-edit-form');


        recordEditForm.submit();
        this.newAppointmentModal = false;
        setTimeout(() => {
            this.newAppointmentModal = true;
        }, 500);


        // setTimeout(() => {
        //     this.newAppointmentModal = true;
        // }, 500);


    }
    handleOptionLocationOnChange(event) {
        this.optionValueLocation = event.detail.value;
        this.getClinics(this.optionValue);
    }

    addDateTimeFlag() {
        this.layoutSections = this.layoutSections.map(section => {
            return {
                ...section,
                layoutRows: section.layoutRows.map(row => {
                    return {
                        ...row,
                        layoutItems: row.layoutItems.map(item => {
                            return {
                                ...item,
                                layoutComponents: item.layoutComponents.map(component => {
                                    return {
                                        ...component,
                                        isOwnerIdOrAppointmentId: component.apiName === 'OwnerId' || component.apiName === 'Name' || component.apiName === 'Clinic_Location__c',
                                        isOwnerId: component.apiName === 'OwnerId',
                                        isClinicLocation: component.apiName === 'Clinic_Location__c'
                                    };
                                })
                            };
                        })
                    };
                })
            };
        });
    }
    handleSaveNewAppointment(event) {
        event.preventDefault();
        const recordEditForm = this.template.querySelector('lightning-record-edit-form');
        recordEditForm.submit();
        this.newAppointmentModal = false;

        this.spinner = true;
        window.location.reload();
        this.initializeCalendar();
        this.spinner = false;

    }

    calendarTitle = '';
    // orgURL = window.location.hostname;
    calendarEl = null;
    calendar = null;
    optionValue = 'Appointment';
    appointments = [];
    eventList = [];
    appointmentDetails = {};
    appointmentDetailModal = false;
    @track allProviderCompanies = [];
    @track allLocations = [];
    @track allProvidersOnCalendar = [];
    allProviderTypesOnCalendar = [];
    allGroupLocationsOnCalendar = [];
    allAffiliatedGroupsOnCalendar = [];

    @track providerOptionsOnCalendar = [];
    @track providerTypesOptionsOnCalendar = [];
    @track groupLocationsOptionsOnCalendar = [];
    @track affiliatedGroupOptionsOnCalendar = [];

    @track selectedAffiliatedgroup = '';
    @track selectedGroupLocation = '';
    @track selectedProviderType = '';
    @track selectedProvider = '';

    @track hiddenEvents = [];
    @track popoverStyle = "";
    @track popoverStyle = {
        backgroundColor: 'white',
        border: '1px solid #ccc',
        padding: '10px',
        borderRadius: '4px'
    };



    connectedCallback() {
        this.subscribeToEvent();
        this.loadProviderList();
        this.loadClinicList();
        this.fetchAllProviders();
        this.fetchAllProviderTypes();
        this.fetchAllGrpLocations();
        this.fetchAllAffiliatedGroups();
        this.optionValue = 'Appointment';
        this.spinner = true;
        this.initializeCalendar();
        this.spinner = false;
        // this.handleOptionOnChange({
        //     detail: { value: this.optionValue }  
        // });
    }
    async fetchAllProviders() {
        await receiveAllProviders({ rand: Math.random() }).then(results => {
            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }
                this.allProvidersOnCalendar = results;
            } else {
                tempArr.push({ label: 'Unavailable', value: 'id' });
            }
            this.providerOptionsOnCalendar = tempArr;
        }).catch(error => {
            console.error('Error:', error);
        });
    }
    async fetchAllProviderTypes() {
        await receiveAllProviderTypes({ rand: Math.random() }).then(results => {
            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }
                this.allProviderTypesOnCalendar = results;
            } else {
                tempArr.push({ label: 'Unavailable', value: 'id' });
            }
            this.providerTypesOptionsOnCalendar = tempArr;

        }).catch(error => {
            console.error('Error:', error);
        });
    }
    async fetchAllGrpLocations() {
        await receiveAllGrpLocations({ rand: Math.random() }).then(results => {
            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }
                this.allGroupLocationsOnCalendar = results;
            } else {
                tempArr.push({ label: 'Unavailable', value: 'id' });
            }
            this.groupLocationsOptionsOnCalendar = tempArr;
            // this.grpLocationOpsUnavailable = tempArr;
        }).catch(error => {
            console.error('Error on fetchAllCareCategories:', error);
        });
    }


     fetchAllAffiliatedGroups() {
         receiveAllAffiliatedGrps({ rand: Math.random() }).then(results => {
            let tempArr = [];
            if (results.length > 0) {
                for (const element of results) {
                    tempArr.push({ label: element.Name, value: element.Id });
                }
                this.allAffiliatedGroupsOnCalendar = results;
            } else {
                tempArr.push({ label: 'No Groups', value: 'id' });
            }
            this.affiliatedGroupOptionsOnCalendar = tempArr;
            console.log('hihi groups' +JSON.stringify(this.affiliatedGroupOptionsOnCalendar));
            // this.grpOptionsUnavailable = tempArr;
        }).catch(error => {
            console.error('Error:', error);
        });
    }
    handleAffiliatedGroupChange(event) {
        this.selectedAffiliatedgroup = event.detail.value;

        this.providerOptionsOnCalendar = [];
        this.providerTypesOptionsOnCalendar = [];
        this.groupLocationsOptionsOnCalendar = [];

        this.selectedGroupLocation = '';
        this.selectedProviderType = '';
        this.selectedProvider = '';

        // console.log('Selected Group: ', this.selectedAffiliatedgroup);
        for (const element of this.allAffiliatedGroupsOnCalendar) {
            if (element.Id == this.selectedAffiliatedgroup) {
                this.filterGroupLocationsOnCalendar(this.selectedAffiliatedgroup);
                this.filterProviderTypeOnCalendar(this.selectedGroupLocation);
                this.filterProviderOnCalendar(this.selectedProviderType, this.selectedGroupLocation);
            }
        }
      
    }

    handleFilters() {
        // Check if the selected filters have valid values
        const isAffiliatedGroupProvided = this.selectedAffiliatedgroup && this.selectedAffiliatedgroup !== 'No Affiliated Group Provided';
        const isGroupLocationProvided = this.selectedGroupLocation && this.selectedGroupLocation !== 'No Group Location Provided';
        const isProviderTypeProvided = this.selectedProviderType && this.selectedProviderType !== '';
        const isProviderProvided = this.selectedProvider && this.selectedProvider !== '';
    
        // Apply filtering based on selected values
        const filteredAppointments = this.appointments.filter((appointment) => {
            const {
                Provider_Company__c,
                Clinic_Location__c,
                Resource_Type__c,
                Clinic_Resource__c,
            } = appointment.extendedProps.appointmentDetail;
    
            // Check for all filter conditions
            if (isProviderProvided) {
                // Filter by provider
                return Clinic_Resource__c === this.selectedProvider;
            } else if (isAffiliatedGroupProvided && isGroupLocationProvided && isProviderTypeProvided) {
                // Filter by affiliated group, group location, and provider type
                return (
                    Provider_Company__c === this.selectedAffiliatedgroup &&
                    Clinic_Location__c === this.selectedGroupLocation &&
                    Resource_Type__c === this.selectedProviderType
                );
            } else if (isGroupLocationProvided && isProviderTypeProvided) {
                // Filter by group location and provider type
                return (
                    Clinic_Location__c === this.selectedGroupLocation &&
                    Resource_Type__c === this.selectedProviderType
                );
            } else if (isGroupLocationProvided) {
                // Filter by group location only
                return Clinic_Location__c === this.selectedGroupLocation;
            } else if (isProviderTypeProvided) {
                // Filter by provider type only
                return Resource_Type__c === this.selectedProviderType;
            } else if (isAffiliatedGroupProvided) {
                // Filter by affiliated group only
                return Provider_Company__c === this.selectedAffiliatedgroup;
            }
    
            // Default case: no filters applied
            return true;
        });
    
        // Load the filtered appointments into the calendar
        this.loadCalendar(filteredAppointments);
        this.closeFilterModal();
    }
    
    handleGroupLocationChange(event) {
        this.selectedGroupLocation = event.detail.value;
        console.log('before calling affiliated Group');
        this.filterAffiliatedGroup(this.selectedGroupLocation);
     
        this.filterProviderTypeOnCalendar(this.selectedGroupLocation);
        this.filterProviderOnCalendar(this.selectedProviderType, this.selectedGroupLocation);
       // this.loadCalendar(filteredAppointments.filter(appointment => appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName === 'Appointment'));
    }
    handleProviderTypeChange(event) {
        this.selectedProviderType = event.detail.value;
        for (const element of this.allProviderTypesOnCalendar) {
            if (element.Id === this.selectedProviderType) {
                this.selectedGroupLocation = element.Clinic_Location__c;
            }
        }
        this.filterAffiliatedGroup(this.selectedGroupLocation);

        this.filterProviderOnCalendar(this.selectedProviderType, this.selectedGroupLocation);
        //this.loadCalendar(filteredAppointments.filter(appointment => appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName === 'Appointment'));

    }
    resetFilter(){
        this.selectedProviderType  = '';
        this.selectedProvider= '';
        this.selectedAffiliatedgroup = '';
        this.selectedgrpLocationID ='';
        this.loadCalendar(this.appointments.filter(appointment => appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName !== 'Unavailable'));
        this.closeFilterModal();

    }
    handleProviderChange(event) {
        this.selectedProvider = event.detail.value;
        for (const element of this.allProvidersOnCalendar) {
            if (element.Id === this.selectedProvider) {

                this.selectedProviderType = element.Resource_Type__c;
                this.selectedGroupLocation = element.Clinic_Location__c;
                this.selectedAffiliatedgroup = element.Clinic_Location__r.Provider_Company__c;
               //// this.filterGroupLocationsOnCalendar(this.selectedAffiliatedgroup);
               // this.filterProviderTypeOnCalendar(this.selectedGroupLocation);

                this.selectedProviderType = element.Resource_Type__c;
                this.selectedGroupLocation = element.Clinic_Location__c;
                this.selectedAffiliatedgroup = element.Clinic_Location__r.Provider_Company__c;

                   console.log('halulu', this.selectedProviderType,  this.selectedGroupLocation , this.selectedAffiliatedgroup )
            
            }
        }
        if (this.selectedAffiliatedgroup === '') {
            this.selectedAffiliatedgroup = 'No Affiliated Group Provided';
        }
        if (this.selectedGroupLocation === '') {
            this.selectedGroupLocation = 'No Group Location Provided';
        }
        if (this.selectedProviderType === '') {
            this.selectedProviderType = 'No Group Location Provided';
        }
       
        // this.loadCalendar(
        //     filteredAppointments.filter(
        //         (appointment) =>
        //             appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName === 'Appointment' ||
        //             appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName === 'Unavailable'
        //     )
        // );
    }
    filterAffiliatedGroup(selectedGroupLocation) {
        console.log('in filter affiliated group: ', this.allGroupLocationsOnCalendar);
        console.log('Selected group Location: ', selectedGroupLocation);
        for (const element of this.allGroupLocationsOnCalendar) {
            if (element.Id === selectedGroupLocation) {
                console.log('Provider_Company__c: ', element.Provider_Company__c);
                this.selectedAffiliatedgroup = element.Provider_Company__c;
                console.log('Selected Affiliated Group: ', this.selectedAffiliatedgroup);
            }
        }
        if (this.selectedAffiliatedgroup === '') {
            this.selectedAffiliatedgroup = 'No Affiliated Group available'
        }
    }
    filterGroupLocationsOnCalendar(selectedAffiliatedgroup) {
        this.groupLocationsOptionsOnCalendar = [];
        console.log('All Affiliated Groups: ', this.allAffiliatedGroupsOnCalendar);
        if (selectedAffiliatedgroup) {
            console.log('In if');
            for (const element of this.allGroupLocationsOnCalendar) {
                if (element.Provider_Company__c == selectedAffiliatedgroup) {
                    console.log('in 2nd if');
                    this.groupLocationsOptionsOnCalendar.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
            }
        } else {
            for (const groupOption of this.affiliatedGroupOptionsOnCalendar) {
                for (const element of this.allGroupLocationsOnCalendar) {
                    if (element.Provider_Company__c === groupOption.value) {
                        this.groupLocationsOptionsOnCalendar.push({
                            label: element.Name,
                            value: element.Id
                        });
                    }
                }
            }
        }

        const isSelectedGrpLocationIDValid = this.groupLocationsOptionsOnCalendar.some(
            option => option.value === this.selectedgrpLocationID
        );
        if (!isSelectedGrpLocationIDValid) {
            this.selectedgrpLocationID = '';
        }
    }
    filterProviderTypeOnCalendar(selectedGroupLocation) {
        this.providerTypesOptionsOnCalendar = [];
        let count = 1;
        for (const element of this.allProviderTypesOnCalendar) {
            if (selectedGroupLocation !== '') {
                if (element.Clinic_Location__c == selectedGroupLocation) {
                    this.providerTypesOptionsOnCalendar.push({
                        label: element.Name,
                        value: element.Id
                    });
                    console.log('Provider Options 1 ' + (count++) + ' : ', this.providerTypesOptionsOnCalendar);
                }

            } else {
                console.log('Group location options: ', this.groupLocationsOptionsOnCalendar);
                for (const grpOption of this.groupLocationsOptionsOnCalendar) {
                    if (grpOption.value === element.Clinic_Location__c) {
                        this.providerTypesOptionsOnCalendar.push({
                            label: element.Name,
                            value: element.Id
                        });
                    }
                }

                console.log('Provider Options 4: ', this.providerTypesOptionsOnCalendar);
            }
        }
        console.log('Provider Options length: ', this.providerTypesOptionsOnCalendar.length);

        // Fallback logic - only runs after the loop
        const isSelectedProviderTypeIDValid = this.providerTypesOptionsOnCalendar.some(
            option => option.value === this.selectedProviderType
        );

        // Update selectedProviderTypeID only if it is invalid
        if (!isSelectedProviderTypeIDValid) {
            if (this.providerTypesOptionsOnCalendar.length > 0) {
                this.selectedProviderType = '';
            } else {
                this.providerTypesOptionsOnCalendar = [{
                    label: 'No Provider Type Found',
                    value: ''
                }];
                this.selectedProviderType = '';
            }
        }
    }
    filterProviderOnCalendar(selectedProviderType, selectedGroupLocation) {
        this.providerOptionsOnCalendar = [];
        if (selectedProviderType === '') {
            for (const providerType of this.providerTypesOptionsOnCalendar) {
                for (const element of this.allProvidersOnCalendar) {

                    if (element.Resource_Type__c === providerType.value) {
                        this.providerOptionsOnCalendar.push({
                            label: element.Name,
                            value: element.Id
                        });
                    }
                }
            }
        } else {
            console.log('in else provider');
            for (const element of this.allProvidersOnCalendar) {

                if (element.Resource_Type__c == selectedProviderType &&
                    element.Clinic_Location__c == selectedGroupLocation) {
                    this.providerOptionsOnCalendar.push({
                        label: element.Name,
                        value: element.Id
                    });
                }
            }
        }
        // Check if the current selectedProvider is still valid
        const isSelectedProviderValid = this.providerOptionsOnCalendar.some(
            option => option.value === this.selectedProvider
        );

        // Update selectedProvider only if it is invalid
        if (!isSelectedProviderValid) {
            if (this.providerOptionsOnCalendar.length > 0) {
                this.selectedProvider = '';
            } else {
                this.providerOptionsOnCalendar = [{
                    label: 'No Provider Found',
                    value: ''
                }];
                this.selectedProvider = '';
            }
        }
        console.log('Filtered Providers: ', this.providerOptionsOnCalendar);
    }
    subscribeToEvent() {
        const messageCallback = (response) => {
            console.log('New platform event received:', response);

            // Trigger calendar refresh whenever a new event is received
            this.initializeCalendar();
        };

        subscribe(this.channelName, -1, messageCallback)
            .then((response) => {
                console.log('Subscribed to Platform Event:', response.channel);
                this.subscription = response;
            })
            .catch((error) => {
                console.error('Error subscribing to Platform Event:', error);
            });

        // Handle any errors in Platform Event subscription
        onError((error) => {
            console.error('Platform Event Error:', error);
        });
    }


    closeModalOnClick() {
        this.appointmentDetailModal = false;
    }

    getClinics(provider) {
        var tempEvents = [];


        if (this.optionValueLocation === 'id') {
            this.optionValueLocation = "id"
            var tempLocations = [];

            this.allLocations.forEach(element => {
                if (element.Provider_Company__c === provider) {
                    tempLocations.push(element);
                }
            })

            tempLocations.forEach(location => {
                this.appointments.forEach(event => {
                    if (location.Id == event.clinicLocation) {
                        tempEvents.push(event);
                    }
                })

            })
            this.loadCalendar(tempEvents);

        } else {

            this.appointments.forEach(event => {

                if (this.optionValueLocation == event.clinicLocation) {
                    tempEvents.push(event);
                }
            })

            this.loadCalendar(tempEvents);
        }
    }


    // handleOptionOnChange(event) {

    //     // this.optionValue = event.detail.value;
    //     // if (this.optionValue === 'id') {
    //     //     this.optionValueLocation = "id"
    //     //     this.enabledLocation = true;
    //     //     this.loadCalendar(this.appointments);
    //     // } else {
    //     //     var options = [];
    //     //     options.push({
    //     //         label: 'All locations',
    //     //         value: 'id'
    //     //     });

    //     //     this.allLocations.forEach((element) => {

    //     //         if (element.Provider_Company__c === event.detail.value) {
    //     //             options.push({
    //     //                 label: element.Name,
    //     //                 value: element.Id
    //     //             });
    //     //         }
    //     //     });

    //     //     this.locationOptions = options;
    //     //     this.enabledLocation = false;
    //     //     this.getClinics(event.detail.value);
    //     // }
    //     this.optionValue = event.detail.value;


    //     if (this.optionValue === 'Appointment') {
    //         // Filter to show only "Appointment" type
    //         this.loadCalendar(this.appointments.filter(appointment => appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName !== 'Unavailable'));
    //     } else if (this.optionValue === 'Unavailable') {
    //         // Filter to show only "Unavailable" type
    //         this.loadCalendar(this.appointments.filter(appointment => appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName === 'Unavailable'));
    //     } else {
    //         // Default: Show all appointments
    //         this.loadCalendar(this.appointments.filter(appointment => appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName !== 'Unavailable'));
    //     }

    // }


    filterAppointments(companyID) {
        var tempEvents = [];
        for (const element of this.appointments) {
            if (element.company == companyID) {
                tempEvents.push(element);
            }
        }

        this.loadCalendar(tempEvents);
    }


    async loadClinicList() {
        var options = [];
        var allLocations = [];

        await retrieveAllClinicLocation().then(response => {
            options.push({
                label: 'All locations',
                value: 'id'
            });

            for (const element of response) {
                options.push({
                    label: element.Name,
                    value: element.Id
                });
            }

            allLocations = response;
            this.locationOptions = options;

        }).catch(error => {
            console.error('Error on: loadProviderList-->', error);
        });

        this.allLocations = allLocations;
    }


    async loadProviderList() {
        var options = [];
        var providers = [];

        await retrieveAllCompanyProviders().then(response => {
            options.push({
                label: 'All Companies',
                value: 'id'
            });

            for (const element of response) {
                options.push({
                    label: element.Name,
                    value: element.Id
                });
            }
            providers = response;

        }).catch(error => {
            console.error('Error on: loadProviderList-->', error);
        });

        this.allProviderCompanies = providers;
        this.calendarSortOptions = options;
    }


    handlePopoverEventClick(event) {
        const clickedEventId = event.currentTarget.dataset.id;
        const clickedEvent = this.hiddenEvents.find(e => e.id === clickedEventId);

        if (clickedEvent) {
            this.handleEventOnClick(clickedEvent);
        }
    }


    async initializeCalendar() {
        console.log("Initializing calendar...");

        var tempEvents = [];
        console.log("Calling retrievePatientAppointments...");
        await retrievePatientAppointments({ rand: Math.random() }).then(async res => {
            console.log("Retrieved appointment data: ", res);
            let parsedRes;
            try {
                parsedRes = JSON.parse(res);
                console.log("Parsed appointment data: ", parsedRes);
            } catch (parseError) {
                console.error("Error parsing JSON response:", parseError);
                return; // Exit early if parsing fails
            }
            try {

                for (const element of JSON.parse(res)) {
                    if (!element.Appointed_Date__c || !element.Start_Time__c || !element.End_Time__c) {
                        console.warn("Skipping invalid record:", element);
                        continue;
                    }
                    let tes = element.Appointed_Date__c + " " + element.Start_Time__c;

                    console.log("Raw start date:", tes);

                    // let dateTime2 = new Date(tes);
                    // console.log("Start time:", dateTime2);

                    // let duration = element.Duration__c;

                    // let minutesToAdd = parseInt(duration.split(' ')[0]); // Extract the number before the first space

                    // let durationInMilliseconds = minutesToAdd * 60 * 1000;

                    // let endDate = new Date(dateTime2.getTime() + durationInMilliseconds);
                    // const recordTypeName = await this.getRecordTypeNameById(element.RecordTypeId);
                    let endDate = element.End_Time__c;
                    console.log("End time:", endDate);


                    // const eventColor = element.From_Outlook__c ? '#FF0000' : '';
                    // const eventTitle = element.From_Outlook__c ? "Unavailable" : (element.Patient_Account__c ? element.Patient_Account__r.Name : "N/A");
                    let recordTypeName = element.RecordType?.DeveloperName || "N/A";

                    // Set color and title based on RecordType DeveloperName
                    let eventColor = '';
                    let eventTitle = '';
                    // if (recordTypeName === 'Unavailable' && this.optionValue === 'Appointment') {
                    //     console.log("Skipping 'Unavailable' record or 'Appointment' type filter:", element);
                    //     continue;
                    // }
                    console.log('appointment type----->' + this.optionValue);
                    // if (recordTypeName === 'Unavailable' && this.optionValue == 'Appointment') {

                    //     continue; // Skip 'Unavailable' appointments
                    // }


                    if (recordTypeName === 'Unavailable') {
                        eventColor = '#ce3e3e'; // Set the event color to red if the record type is 'Unavailable'
                    }

                    const timeString = element.End_Time__c.slice(0, 5); // Extract "HH:MM"
                    const [hours, minutes] = timeString.split(":").map(Number);
                    
                    const period = hours >= 12 ? "PM" : "AM";
                    const formattedHours = hours % 12 || 12;
                    const formattedTime = `${formattedHours}:${minutes.toString().padStart(2, "0")} ${period}`;
                    
                    console.log(formattedTime); // Example Output: "8:15 AM"
                    

                    
                    const timeString2 = element.Start_Time__c.slice(0, 5); // Extract "HH:MM"
                    const [hours2, minutes2] = timeString2.split(":").map(Number); // Split into hours and minutes
                    
                    const period2 = hours2 >= 12 ? "PM" : "AM"; // Determine AM or PM
                    const formattedHours2 = hours2 % 12 || 12; // Convert to 12-hour format (handle midnight as 12)
                    
                    const formattedTime2 = `${formattedHours2}:${minutes2.toString().padStart(2, "0")} ${period2}`;
                    console.log(formattedTime2); // Output: "8:15 AM" (if Start_Time__c is "08:15")
                    
                    eventTitle = `<b> ${formattedTime2} - ${formattedTime}</b> • ${element.Patient_Account__r?.Name || 'N/A'}`;
                  //  eventTitle = `<b>- ${formattedTime}</b>. ${element.Patient_Account__r?.Name}`|| 'N/A';
                                        // eventTitle = `<b>- </b>. ${element.Patient_Account__r?.Name}`;`;

                  //  eventTitle = ('-'+formattedTime+element.Patient_Account__r?.Name) || "N/A"; // Safe access with fallback
                    console.log("Event title:", eventTitle);
                    const event = {
                        id: element.Id,
                        // company: element.Provider_Company__c ? element.Provider_Company__c : null,
                        title: eventTitle,
                        start: tes,

                        end: endDate,
                        color: eventColor,
                        allDay: false,
                        // clinicName:element.Clinic_Location__r.Name ,
                        clinicLocation: element.Clinic_Location__c || null,
                        extendedProps: {
                            appointmentDetail: element
                        }
                    };

                    tempEvents.push(event);
                }
            } catch (loopError) {
                console.error("Error processing appointment records:", loopError);
            }

        }).catch(error => {
            console.log('error.......');
            console.error('Error on retrievePatientAppointments--->', JSON.stringify(error));
        });

        // this.appointments = tempEvents;
        this.appointments = [...tempEvents];


        console.log("Appointments array populated:", this.appointments);
        console.log("appoitment array ending..............");


        // this.loadCalendar(this.appointments);
        this.loadCalendar(this.appointments.filter(appointment => appointment.extendedProps.appointmentDetail.RecordType?.DeveloperName !== 'Unavailable'));

    }

    handleMoreLinkClick(info) {
        setTimeout(() => {
            let morePopoverlist = document.querySelectorAll('.fc .fc-popover');
            let morePopover = morePopoverlist[morePopoverlist.length - 1];

            morePopover.style.zIndex = '8';

            if (morePopover) {
                const clonedPopover = morePopover.cloneNode(true);
                morePopover.parentNode.replaceChild(clonedPopover, morePopover);
                morePopover = clonedPopover;

                const clickedEvents = morePopover.querySelectorAll('.fc-event');

                clickedEvents.forEach((eventEl, index) => {
                    eventEl.addEventListener('click', (e) => {
                        e.preventDefault();
                        e.stopPropagation();
                        this.handleEventOnClick(info.allSegs[index]);

                    });
                });

                const closeIcon = morePopover.querySelector('.fc-popover-close');

                if (closeIcon) {
                    closeIcon.addEventListener('click', (event) => {
                        event.preventDefault();
                        event.stopPropagation(); // Prevent any further propagation of the event
                        morePopover.style.display = 'none'; // Hide the popover
                        morePopover.style.visibility = 'hidden'; // Set visibility to hidden
                        // console.log('Popover closed via close icon');
                    });
                }

                // const handleClickOutside = (event) => {

                //     if (morePopover && !morePopover.contains(event.target)) {
                //         morePopover.style.display = 'none';
                //         morePopover.style.visibility = 'hidden';
                //         document.removeEventListener('click', handleClickOutside);
                //     }
                // };
                // setTimeout(() => {
                //     document.addEventListener('click', handleClickOutside);
                // }, 200); // A


            }
        }, 100); // Delay to ensure the popover is created before adding listeners
    }


    async loadCalendar(events) {
        console.log('Loading Calendar...');


        await Promise.all([
            loadStyle(this, FullCalendarJS + '/main.css'),
            loadScript(this, FullCalendarJS + '/main.js')
        ]).then(() => {
            console.log('info');

            this.calendarEl = this.template.querySelector('div.fullcalendar');

            const flag = true;


            this.calendar = new FullCalendar.Calendar(this.calendarEl, {

                headerToolbar: false,
                eventContent: function(info) {
                    return { html: info.event.title }; // Render the HTML title
                },
                initialDate: new Date(),
                showNonCurrentDates: true,
                fixedWeekCount: false,
                allDaySlot: false,
                navLinks: false,
                eventClick: (info) => {
                    console.log("clicked" + info.event.id);
                    info.jsEvent.preventDefault();
                    info.jsEvent.stopPropagation();
                    this.handleEventOnClick(info);
                },
                events: events,
                timeZone: 'UTC',
                eventDisplay: 'block',
                eventTimeFormat: {
                    hour: 'numeric',
                    minute: '2-digit',
                    omitZeroMinute: true,
                    meridiem: 'short'
                },

                dayMaxEvents: 2,

                moreLinkClick: (info) => {
                    console.log("More link clicked:", info);

                    this.handleMoreLinkClick(info);

                }


            });

            this.calendar.setOption('contentHeight', 650);


            this.calendarTitle = this.calendar.view.title;


            this.calendar.render();

        }).catch(error => console.log(error));
    }

    calendarActionsHandler(event) {
        const actionName = event.target.value;
        if (actionName === 'previous') {
            this.calendar.prev();
        } else if (actionName === 'next') {
            this.calendar.next();
        } else if (actionName === 'today') {
            this.calendar.today();
        } else if (actionName === 'new') {

        } else if (actionName === 'refresh') {
            this.spinner = true;
            this.initializeCalendar();
            this.spinner = false;
        }else if(actionName === 'filter'){
            // this.filter = true;
            this.handlefilterModal();
        }

        this.calendarTitle = this.calendar.view.title;
    }
    @track isExpanded = true;
    @track isAppointment = true;
     handlefilterModal(){
  this.filter = true;
  this.isExpanded = true;
  this.isAppointment = true;


    }

    viewOptions = [
        {
            label: 'Day',
            viewName: 'timeGridDay',
            checked: false
        },
        {
            label: 'Week',
            viewName: 'timeGridWeek',
            checked: false
        },
        {
            label: 'Month',
            viewName: 'dayGridMonth',
            checked: true
        }
    ];


    changeViewHandler(event) {
        const viewName = event.detail.value;
        if (viewName != 'listView') {
            this.calendar.changeView(viewName);
            const viewOptions = [...this.viewOptions];
            for (let viewOption of viewOptions) {
                viewOption.checked = false;
                if (viewOption.viewName === viewName) {
                    viewOption.checked = true;
                }
            }
            this.viewOptions = viewOptions;
            this.calendarTitle = this.calendar.view.title;
        } else {
            // this.handleListViewNavigation('Appointment__c');
        }
    }

    closeFilterModal(){
        this.filter= false;
    }

    handleEventOnClick(info) {

        var temp = {
            id: null,
            appointmentID: null,
            patientName: null,
            patientId: null,
            clinicName: null,
            doctorName: null,
            doctorNameID: null,
            location: null,
            date: null,
            time: null,
            startTime: null,
            endTime: null,
            roomLevel: null,
            roomLabel: null,
            locationAddress: null,
            duration: null,
            locationName: null,
            providerName: null,
            originalDate: null,
            AppointmentType: null,
            ProviderType: null,
            careCategory: null,
            recordType: null,
            roomType: null,
            telehealth: null,
            provider: null,
            locationID: null,
            note: null
        };


        // let tes = this.changeTimezoneOffset(info.event.extendedProps.appointmentDetail.Format_Date_For_Email__c);

        const address = (info.event.extendedProps.appointmentDetail.Provider_Company__r) ? info.event.extendedProps.appointmentDetail.Provider_Company__r.Address__c : 'N/A';
        const addressString = (address != '') ? `${address.street}, ${address.city}, ${address.stateCode} ${address.postalCode}, ${address.country}` : 'N/A';

        temp.id = info.event.id;
        temp.duration = info.event.extendedProps.appointmentDetail.Duration__c ? info.event.extendedProps.appointmentDetail.Duration__c : "N/A";
        temp.telehealth = info.event.extendedProps.appointmentDetail.Telehealth__c ? info.event.extendedProps.appointmentDetail.Telehealth__c : "N/A";
        temp.roomType = info.event.extendedProps.appointmentDetail.Room_Type__c ? info.event.extendedProps.appointmentDetail.Room_Type__c : "N/A";
        temp.AppointmentTypeName = info.event.extendedProps.appointmentDetail.Appointment_Type__c ? info.event.extendedProps.appointmentDetail.Appointment_Type__r.Name : "N/A";

        temp.AppointmentType = info.event.extendedProps.appointmentDetail.Appointment_Type__c ? info.event.extendedProps.appointmentDetail.Appointment_Type__c : "N/A";

        temp.ProviderType = info.event.extendedProps.appointmentDetail.Resource_Type__c ? info.event.extendedProps.appointmentDetail.Resource_Type__c : "N/A";
        temp.ProviderTypeName = info.event.extendedProps.appointmentDetail.Resource_Type__c ? info.event.extendedProps.appointmentDetail.Resource_Type__r.Name : "N/A";
        temp.careCategory = info.event.extendedProps.appointmentDetail.Resource_Category__c ? info.event.extendedProps.appointmentDetail.Resource_Category__c : "N/A";
        temp.careCategoryName = info.event.extendedProps.appointmentDetail.Resource_Category__c ? info.event.extendedProps.appointmentDetail.Resource_Category__r.Name : "N/A";
        temp.recordType = info.event.extendedProps.appointmentDetail.RecordTypeId ? info.event.extendedProps.appointmentDetail.RecordTypeId : "N/A";
        // temp.originalDate = info.event.extendedProps.appointmentDetail.Date_and_Time_Temp__c;

        temp.appointmentID = info.event.extendedProps.appointmentDetail ? info.event.extendedProps.appointmentDetail.Name : "N/A";
        // temp.patientName = info.event.extendedProps.appointmentDetail.Patient__r.Name;
        temp.clinicName = info.event.extendedProps.appointmentDetail.Clinic_Location__c ? info.event.extendedProps.appointmentDetail.Clinic_Location__r.Provider_Company__c : "N/A";
        temp.doctorNameID = (info.event.extendedProps.appointmentDetail.Clinic_Resource__c) ? info.event.extendedProps.appointmentDetail.Clinic_Resource__c : 'N/A';
        temp.doctorName = (info.event.extendedProps.appointmentDetail.Clinic_Resource__c) ? info.event.extendedProps.appointmentDetail.Clinic_Resource__r.Name : 'N/A';
        // temp.location = (addressString == '') ? 'No Address Provided' : addressString;
        temp.location = (info.event.extendedProps.clinicLocation) ? info.event.extendedProps.clinicLocation : "N/A";
        temp.patientId = (info.event.extendedProps.appointmentDetail.Patient_Account__c) ? info.event.extendedProps.appointmentDetail.Patient_Account__c : "N/A";
        // temp.date = tes.split('T')[0];
        temp.date = info.event.extendedProps.appointmentDetail.Appointed_Date__c;

        let time = info.event.extendedProps.appointmentDetail.Start_Time__c;
        let end_time = info.event.extendedProps.appointmentDetail.End_Time__c;

        temp.startTime = this.reformatTime(time.split('.')[0]);
        temp.endTime = this.reformatTime(end_time.split('.')[0]);
        temp.patientName = (info.event.extendedProps.appointmentDetail.Patient_Account__c) ? info.event.extendedProps.appointmentDetail.Patient_Account__r.Name : "N/A";
        temp.roomLevel = (info.event.extendedProps.appointmentDetail.Room_Level__c) ? info.event.extendedProps.appointmentDetail.Room_Level__c : "N/A";
        temp.roomLabel = (info.event.extendedProps.appointmentDetail.Room_Label__c) ? info.event.extendedProps.appointmentDetail.Room_Label__c : "N/A";
        temp.locationName = (info.event.extendedProps.appointmentDetail.Clinic_Location__c) ? info.event.extendedProps.appointmentDetail.Clinic_Location__r.Name : "N/A";
        temp.locationID = (info.event.extendedProps.appointmentDetail.Clinic_Location__c) ? info.event.extendedProps.appointmentDetail.Clinic_Location__c : "N/A";
        temp.locationAddress = (info.event.extendedProps.appointmentDetail.Clinic_Location__r.Address_Text__c) ? info.event.extendedProps.appointmentDetail.Clinic_Location__r.Address_Text__c : "N/A";
        temp.provider = (info.event.extendedProps.appointmentDetail.Clinic_Location__c) ? (info.event.extendedProps.appointmentDetail.Clinic_Location__r.Provider_Company__c ? info.event.extendedProps.appointmentDetail.Clinic_Location__r.Provider_Company__r : "N/A") : "N/A";
        temp.providerName = (info.event.extendedProps.appointmentDetail.Clinic_Location__c) ? (info.event.extendedProps.appointmentDetail.Clinic_Location__r.Provider_Company__c ? info.event.extendedProps.appointmentDetail.Clinic_Location__r.Provider_Company__r.Name : "N/A") : "N/A";
        temp.note = (info.event.extendedProps.appointmentDetail.Description__c) ? info.event.extendedProps.appointmentDetail.Description__c : "N/A";
        this.appointmentDetails = temp;
        this.appointmentDetailModal = true;
    }

    handleActiveTab(event) {
        const tab = event.target;
        this.tabContent = `Tab ${event.target.value} is now active`;
        this.activeTab = event.target.value;

    }
    getClinicLocation(event) {
        this.location = event.detail.value;

    }


    async searchLocation(originAddress) {
        try {
            const result = await getClosestClinicLocationId({ originAddress: originAddress });
            this.closestClinicId = result;
            if (this.closestClinicId == null) {
                this.ClinickNotFoundMsg = "Clinic not found with this location"
            } else {
                this.ClinickNotFoundMsg = "";

            }
            this.spinner = false;

            this.activeTab = 'tab2'

        } catch (error) {
            console.error('Error fetching closest clinic:', error);
            this.spinner = false;
        }
    }

    handleLocationSearchClick(event) {
        this.spinner = true;
        this.searchLocation(this.location);
    }

    reformatTime(time) {
        let meridiem = 'AM';
        let hours = parseInt(time.split(':')[0]);

        if (hours <= 12) {
            if (hours == 12) {
                meridiem = 'PM';
            }
            return time.split(':')[0] + ':' + time.split(':')[1] + ' ' + meridiem;
        }

        hours = hours - 12;
        meridiem = 'PM';

        return hours.toString() + ':' + time.split(':')[1] + ' ' + meridiem;
    }
    changeTimezoneOffset(dateString) {
        // console.log("ihiu" + dateString);
        // Replace the last 5 characters (timezone part) with +0000
        return dateString.slice(0, -5) + "+0000";
    }

    async reloadCalendar(event) {
        await this.initializeCalendar();
        this.newRecordTypeModal = false;
    }


}