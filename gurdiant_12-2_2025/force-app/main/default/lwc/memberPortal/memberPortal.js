import { LightningElement,track ,wire } from 'lwc';
import retrieveClosestClinicLocationId from '@salesforce/apex/DistanceService.getClosestClinicLocationId';
import getClinicLocationNameById from '@salesforce/apex/DistanceService.getClinicLocationNameById';
import getAvailableSlots from '@salesforce/apex/MemberPortalController.getAvailableAppointmentSlots';
import getAllProviders from '@salesforce/apex/MemberPortalController.getAllProviders';
import getAvailableTimeSlots from '@salesforce/apex/MemberPortalController.getAvailableTimeSlots';
// import createAppointment from '@salesforce/apex/PatientFormController.createAppointment';
import { NavigationMixin } from 'lightning/navigation';
import getAllAppTypes from '@salesforce/apex/MemberPortalController.getAllAppTypes';
import getAllCareCat from '@salesforce/apex/MemberPortalController.getAllCareCategories';


export default class MemberPortal extends LightningElement {

    @track providerOptions = [];
@track weeks = ['Sun', 'Mon','Tue', 'Wed', 'Thu','Fri','Sat'];
@track clinicName = '';  // To store the clinic name
@track clinicName1 = false; 
@track ClinickNotFoundMsg = '';  // To store a message when no clinic is found
@track availableSlots ;
appTypesOptions  =[]
careCatOptions = [];
@track days = []
selectedMonth = '';
 selectedYear = '';
 selectedDay = '';
 //selectedDate = '';
 clickedDay ='';
 @track clickedFullDate = 'Select a Date';
 @track availableTimes = [];
 @track timeOptions = [];
 @track selectedTime = 16;
 thisDay ;
//  scrollToBottom() {
//     const container = this.template.querySelector('.list-container');
//     container.scrollTop = container.scrollHeight;
// }

    handleScrollState() {
        console.log(' hello my name scroll ');
        const container = this.template.querySelector('.list-container');
        const topArrow = this.template.querySelector('.scroll-arrow-top');
        const bottomArrow = this.template.querySelector('.scroll-arrow-bottom');
    
        // Check if the container is at the top
   // Ensure the container and arrows are found before applying logic
   if (!container || !topArrow || !bottomArrow) {
    console.warn('Some elements are missing in handleScrollState');
    return;
}else{
    console.log(' huhuhuhuhuhuhuhuhuhuhu ');
}

// Check if the container is at the top
if (container.scrollTop === 0) {
    console.log('1');
    topArrow.classList.add('disabled');
    topArrow.classList.remove('enabled');
} else {
    console.log('2');
    topArrow.classList.add('enabled');
    topArrow.classList.remove('disabled');
}

// Check if the container is at the bottom
if (container.scrollTop + container.clientHeight >= container.scrollHeight) {
    console.log(' hummmmmmm ');
    bottomArrow.classList.add('disabled');
    bottomArrow.classList.remove('enabled');
} else {
    console.log(' huiiiiiiiiiiiiimmmmmmm ');
    bottomArrow.classList.add('enabled');
    bottomArrow.classList.remove('disabled');
}
    
        // Check if the container is at the bottom
        // if (container.scrollTop + container.clientHeight >= container.scrollHeight) {
        //     bottomArrow.classList.add('disabled');
        //     bottomArrow.classList.remove('enabled');
        // } else {
        //     bottomArrow.classList.add('enabled');
        //     bottomArrow.classList.remove('disabled');
        // }
    }


scrollToBottom() {
    const container = this.template.querySelector('.list-container');
    container.scrollTo({
        top: container.scrollHeight,
        behavior: 'smooth', // Smooth scrolling
    }); 
   // setTimeout(() => this.handleScrollState(), 300);
   this.handleScrollState();
}
scrollToTop() {
    const container = this.template.querySelector('.list-container');
    container.scrollTo({
        top: 0, // Scroll to the top
        behavior: 'smooth', // Smooth scrolling
    });
    //setTimeout(() => this.handleScrollState(), 300); 
    this.handleScrollState();
}



 radioRecordOptions = [
    { label: 'New Member', value: 'New Member' },
    { label: 'Returning Member', value: 'Returning Member' }
];
timeZoneOption = [
    {label : 'USA(PST)' , value : 'USA(PST)'},
    {label : 'USA(MST)' , value :'USA(MST)'},
    {label : 'USA(CST)' , value : 'USA(CST)'},
    {label : 'USA(EST)' , value : 'USA(EST)'},
    {label : 'USA(AKST)' , value : 'USA(AKST)'},
    {label : 'USA(HST)' , value : 'USA(HST)'},
]
telepathOption=[
    {label : 'Yes' , value : 'Yes'},
    {label : 'No' , value : 'No'},
]
providerLanguageOption = [
    {label : 'English' , value : 'English'},
    {label : 'Spanish' , value : 'Spanish'},
    {label : 'Chinese' , value : 'Chinese'},
    {label : 'Korean' , value : 'Korean'},
    {label : 'Bengali' , value : 'Bengali'},
    {label : 'French' , value : 'French'},
]
addressRedusOption = [
    {label : '15 mi ', value :'15 mi ' },
    {label : '30 mi ', value :'30 mi '},
    {label : '60 mi ', value :'60 mi '},
    {label : '120 mi ', value :'120 mi '},
    {label : '200 mi ', value :'200 mi '},
]
selectedRecordTypeValue  = 'New Member';

newMember= true;
returningMember = false;

@track availableTimeSlots = {}; 
@wire(getAvailableTimeSlots, { nextNDays: 7, providerID: '' })
wiredAvailableTimeSlots({ error, data }) {
    if (data) {
        console.log(' okokokok ');
        this.availableTimeSlots = data;



          // Format the date to check
          const targetDate = '2025-01-12';

          // Convert object keys to a standard format (YYYY-MM-DD)
          const formattedDates = Object.keys(this.availableTimeSlots).map(dateString => {
              const dateObj = new Date(dateString); // Convert to Date object
              return dateObj.toISOString().split('T')[0]; // Format as 'YYYY-MM-DD'
          });
  
          // Check if the target date exists in the formatted dates
          const dateExists = formattedDates.includes(targetDate);
  
          console.log(`Does ${targetDate} exist?`, dateExists);


          this.initializeDate();
          this.generateDaysForCurrentMonth();
        //  this.fetchProviders();
        
               //     this.availableSlots = new Map(
               //     Object.entries(this.dateTimeMap).map(([date, timesObj]) => [
               //         date,
               //         new Map(Object.entries(timesObj))
               //     ])
               // );
               //         this.initializeDate();
               // this.generateDaysForCurrentMonth();
       this.fetchProviders();
   this.fetchAppTypes();
   this.fetchCareCat();
   const formattedDate = this.selectedDate.toISOString().split('T')[0];
   console.log(formattedDate); // Output: 2025-01-13
      this.selectedDate = formattedDate;
      this.filterTimeSlots();

    } else if (error) {
        console.error('Error fetching available time slots', error);
    }
}

handleRadioRecordChange(event) {
    this.selectedRecordTypeValue = event.detail.value;
    if( this.selectedRecordTypeValue == 'New Member'){
       this.newMember = true;
        this.returningMember = false;
    }else{
        this.newMember = false;
        this.returningMember = true;
    }
}

 @track dateTimeMap = new Map([
    // ['2025-01-09', ['12:15 PM', '1:15 PM', '2:30 PM' , '3:30 PM', '4:30 PM', '5:30 PM']],
    // ['1/9/2025', ['12:15 PM', '1:15 PM', '2:30 PM']],
    // ['1/10/2025', ['12:15 PM', '1:15 PM', '2:30 PM' , '3:30 PM', '4:30 PM', '5:30 PM']],
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
@track tempTimeOptions =[];
@track filteredTimeSlots =[];
@track sectedProviderLanguage = '';
connectedCallback() {

   let dateeTimeMap = new Map();
   this.formData ['providerGender'] = 'English';
   this.sectedProviderLanguage = 'English';
   const container = this.template.querySelector('.list-container');
    if (container) {
        container.addEventListener('scroll', (event) => {
            this.handleScrollState(event); // Arrow function ensures the correct `this`
        });
    }
//    const container = this.template.querySelector('.list-container');
//    container.addEventListener('scroll', this.handleScroll.bind(this));

       
}
renderedCallback() {
    const container = this.template.querySelector('.list-container');
    if (container && !this.scrollListenerAttached) {
        container.addEventListener('scroll', this.handleScrollState.bind(this));
        this.scrollListenerAttached = true; // Prevent multiple event listeners
    }
}

// renderedCallback() {
//     // Ensure the container exists before attaching the event listener
//     const container = this.template.querySelector('.list-container');
//     if (container && !this.scrollListenerAttached) {
//         container.addEventListener('scroll', this.handleScroll.bind(this));
//         this.scrollListenerAttached = true; // Prevent multiple listeners from being added
//     }
// }
disconnectedCallback() {
    // Remove the scroll event listener when the component is removed from the DOM
    const container = this.template.querySelector('.list-container');
    if (container) {
        container.removeEventListener('scroll', this.handleScrollState.bind(this));
    }
}
fetchProviders() {
    getAllProviders()
        .then((result) => {
            this.providerOptions = result.map((provider) => ({
                label: provider.Name,
                value: provider.Id,
            }));
    
        })
        .catch((error) => {
            console.error('Error fetching providers: ', error);
        });
}
fetchAppTypes() {
    getAllAppTypes()
        .then((result) => {
            this.appTypesOptions = result.map((provider) => ({
                label: provider.Name,
                value: provider.Id,
            }));
        




        })
        .catch((error) => {
            console.error('Error fetching providers: ', error);
        });
}
fetchCareCat() {
    getAllCareCat()
        .then((result) => {
            
            this.careCatOptions = result.map((provider) => ({
                label: provider.Name,
                value: provider.Id,
            }));
        })
        .catch((error) => {
            console.error('Error fetching providers: ', error);
        });
}
@track isExpanded = true;
@track isExpandedPreferences = true;
@track isExpandedDT = true;
@track isExpandedReturningRequired = true;
@track selectedDate; 
// @track isExpandedSection2 = true;

toggleSection() {
    this.isExpanded = !this.isExpanded;
    // console.log("hmm" + this.isExpanded);
}
togglePrefSection() {
    this.isExpandedPreferences = !this.isExpandedPreferences;
    // console.log("hmm" + this.isExpanded);
}
toggleDTSection() {
    this.isExpandedDT = !this.isExpandedDT;
    // console.log("hmm" + this.isExpanded);
}
toggleReturningRequired() {
    this.isExpandedReturningRequired = !this.isExpandedReturningRequired;
    // console.log("hmm" + this.isExpanded);
}
@track isAppointment = true; 
//calender code starts
initializeDate() {
    const currentDate = new Date();
    this.selectedDate = currentDate;
    this.selectedYear = currentDate.getFullYear();
    this.selectedMonth = currentDate.toLocaleString('default', { month: 'long' });
    console.log("hhh"+this.selectedMonth);
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
           console.log("loop "+(!pastDay)+" "+today);
        //   console.log(pastDay +'jjj '+)
           if(!pastDay && !today){
            today = true;
          this.thisDay = day;
            this.days.push({
                day: day,
                isPast: pastDay,
               // isPast:false,
                isToday:true
            });
           }else{
            this.days.push({
                day: day,
                isPast: pastDay,
                //isPast:false,
                isToday:false
            });

           }        
}
const selectedDay = this.thisDay; 
console.log("i m here"+selectedDay);
console.log(this.duration);
this.clickedDay = selectedDay;

const date = this.selectedYear +"-"+ (this.getMonthIndex(this.selectedMonth) + 1)+"-"+this.clickedDay;
this.clickedFullDate =date;

console.log("Selected Day: ", this.clickedDay); 
let formattedDate = date.replace(/(\d{4})-(\d{2})-(\d{2})/, '$2/$3/$1');
this.availableTimes = this.dateTimeMap.get(formattedDate) || [];

console.log( "hummm"+JSON.stringify(this.availableTimes ));

this.setTimeOptions();
}
handlePrev(){
    console.log("clicked prev");
    let currentDate = new Date(this.selectedYear, this.getMonthIndex(this.selectedMonth) - 1);
    this.updateDate(currentDate);
    this.generateDaysForCurrentMonth();
}
handleNext(){
    console.log("clicked next");
    let currentDate = new Date(this.selectedYear, this.getMonthIndex(this.selectedMonth) + 1);
    console.log(currentDate);
    this.updateDate(currentDate);
    this.generateDaysForCurrentMonth();
}
handleSelectedDate(event) {
    const previouslySelected = this.template.querySelector('.selected');
    if (previouslySelected) {
        previouslySelected.classList.remove('selected');
    }
    const clickedElement = event.target;
    clickedElement.classList.add('selected');

    const selectedDay = event.target.dataset.day; 
    console.log(this.duration);
    this.clickedDay = selectedDay;
   
    const date = this.selectedYear +"-"+ (this.getMonthIndex(this.selectedMonth) + 1)+"-"+this.clickedDay;
    this.clickedFullDate =date;
    
    console.log("Selected Day: ", this.clickedDay); 
   // let formattedDate = date.replace(/(\d{4})-(\d{2})-(\d{2})/, '$2/$3/$1');
   let formattedDate = date.replace(/(\d{4})-(\d{1,2})-(\d{1,2})/, (_, year, month, day) => {
    const formattedMonth = month.padStart(2, '0'); // Ensures 2 digits for the month
    const formattedDay = day.padStart(2, '0');     // Ensures 2 digits for the day
    return `${year}-${formattedMonth}-${formattedDay}`;
});



   //// this.availableTimes = this.dateTimeMap.get(formattedDate) || [];

   // console.log( "hummm"+JSON.stringify(this.availableTimes ));
    this.selectedDate = formattedDate;
    console.log('selecetd '+formattedDate);
    this.setTimeOptions();



    this.filterTimeSlots();

}
 scrollEnabled = false; 
filterTimeSlots() {
    console.log('hihih');
    this.filteredTimeSlots = [];
  // Format the date to check
  const targetDate = this.selectedDate;
   console.log(' i m selected date dear ' +this.selectedDate);
  // Convert object keys to a standard format (YYYY-MM-DD)
  var originalKey ='';

  const formattedDates = Object.keys(this.availableTimeSlots).map(dateString => {
      const dateObj = new Date(dateString); // Convert to Date object
      //originalKey = dateString;
      return dateObj.toISOString().split('T')[0]; // Format as 'YYYY-MM-DD'
  });
  console.log(' hiin ' );

  // Check if the target date exists in the formatted dates
  const dateExists = formattedDates.includes(targetDate);
  console.log(' hiin '+ dateExists );
   if(dateExists ){
    const originalKey = Object.keys(this.availableTimeSlots).find(dateString => {
        const dateObj = new Date(dateString); // Convert to Date object
        return dateObj.toISOString().split('T')[0] === targetDate;
   })
   if (this.selectedDate && this.availableTimeSlots[originalKey]) {

    this.selectedTime = 15;

     const slots = this.availableTimeSlots[originalKey];
     this.filteredTimeSlots =  slots
 .filter(slot=>{
  return slot.maxDuration>= this.selectedTime
 })
          .map(slot => ({
             label: this.formatTime(slot.timee)    , // Display-friendly formatted time
             value: this.formatTime(slot.timee)             // Use raw time as the unique value
         }));
         if(this.filteredTimeSlots.length>4){
            this.scrollEnabled = true; 
         }else{
             this.scrollEnabled = false;
         }
      
     
       
         
 } else {
     this.filteredTimeSlots = []; // No slots for the selected date
 }


   }
 //  console.log(dateExists);

}
formatTime(ms) {
    const hours = Math.floor(ms / 3600000); // Convert to hours
    const minutes = Math.floor((ms % 3600000) / 60000); // Convert to minutes
    
    // Determine AM or PM
    const period = hours >= 12 ? 'PM' : 'AM';

    // Convert 24-hour format to 12-hour format
    const hours12 = hours % 12 || 12; // If hours is 0 (midnight), show as 12

    // Pad with leading zeros for hours and minutes
    return `${hours12.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')} ${period}`;
}

// formatTime(time) {
//     let date = new Date(time);
//     return `${date.getHours()}:${date.getMinutes()}`;
// }
setTimeOptions() {
    
  let formattedDate = this.clickedFullDate.replace(/(\d{4})-(\d+)-(\d+)/, (_, year, month, day) => {
    return `${parseInt(month)}/${parseInt(day)}/${year}`;
});

  this.availableTimes = this.dateTimeMap.get(formattedDate) || [];

  this.timeOptions = this.availableTimes.map(time => {
    if(parseInt(time,10)>12){
        time = parseInt(time, 10) - 12;
        console.log(time);
        time = '0'+time + ":00 PM";
    }else{
        console.log('oho'+ time);
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

    console.log("time options: ", JSON.stringify(this.timeOptions));
}
updateDate(date) {
    this.selectedYear = date.getFullYear();
    this.selectedMonth = date.toLocaleString('default', { month: 'long' });
    console.log("update from"+this.selectedMonth)
}
getMonthIndex(month) {
    return new Date(Date.parse(month + " 1, 2020")).getMonth();
}
isPastDate(day) {
    const monthIndex = this.getMonthIndex(this.selectedMonth); 
     console.log("i m month"+monthIndex);
     console.log(this.selectedYear);

    const selectedDate = new Date(this.selectedYear, monthIndex,day );

    const date = this.selectedYear +"-"+ (this.getMonthIndex(this.selectedMonth) + 1)+"-"+day;
    // let formattedDate = date.replace(/(\d{4})-(\d+)-(\d+)/, (_, year, month, day) => {
    //     return `${parseInt(month)}/${parseInt(day)}/${year}`;
    // });
    console.log(date);
    let formattedDate = date.replace(/(\d{4})-(\d{1,2})-(\d{1,2})/, (_, year, month, day) => {
        const formattedMonth = month.padStart(2, '0'); // Ensures 2 digits for the month
        const formattedDay = day.padStart(2, '0');     // Ensures 2 digits for the day
        return `${year}-${formattedMonth}-${formattedDay}`;
    });

    const inputDate = new Date(formattedDate);

// Get the current date (without time)
const currentDate = new Date();
currentDate.setHours(0, 0, 0, 0); // Remove time part from the current date

// Compare the two dates
if (inputDate < currentDate) {
    console.log('The date is in the past.');
    return true;;
} else if (inputDate >= currentDate) {
    console.log('The date is in the future.');

    const formattedDates = Object.keys(this.availableTimeSlots).map(dateString => {
        const dateObj = new Date(dateString); // Convert to Date object
        //originalKey = dateString;
        return dateObj.toISOString().split('T')[0]; // Format as 'YYYY-MM-DD'
    });
  
    // Check if the target date exists in the formatted dates
    const dateExists = formattedDates.includes(formattedDate);
     if(dateExists ){

        return false;
     }else{
        return true;
     }


} 

    console.log("oo"+formattedDate);
       

    console.log("i m " +availableTimes.length);
       console.log(JSON.stringify(availableTimes));
    
    selectedDate.setHours(0, 0, 0, 0);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
     console.log(selectedDate+" "+today);
   console.log("i m proma");
     console.log(selectedDate+" "+today);
     console.log(availableTimes.length);
     console.log((selectedDate < today) + " "+availableTimes.length);
    return ((selectedDate < today) || (availableTimes.length == 0));
}
handleTimeSelect(event) {
    this.selectedTime = event.detail.value;
    console.log("Selected Time: ", this.selectedTime);
}
handleTimeChange(event){
    this.selectedTime = event.detail.value;
    console.log("Selected Time: ", this.selectedTime);
}

//calender code ends


@track patientName = '';
@track email = '';
@track gender = '';
@track dob = '';
@track searchQuery = '';
@track customObjectLookup = '';
@track closestClinicId = null;
@track location = "";
@track duration = "15 minutes";
@track clinicAddress = "";

get genderOptions() {
    return [
        { label: 'Male', value: 'male' },
        { label: 'Female', value: 'female' },
        { label: 'Other', value: 'other' }
    ];
}
@track durationOptions = [
    { label: '15 minutes', value: '15 minutes' },
    { label: '30 minutes', value: '30 minutes' },
    { label: '60 minutes', value: '60 minutes' }
];

@track duration = '0'; // To store the selected duration value

// Handle the input change for the duration combobox
// handleInputChange(event) {
//     const field = event.target.dataset.id;
//     if (field === 'duration') {
//         this.duration = event.target.value;
//         console.log("Selected Duration: ", this.duration);
//     }
// }

// handleInputChange(event) {
//     const field = event.target.dataset.id;
//     if (field === 'patientName') {
//         this.patientName = event.target.value;
//     } else if (field === 'email') {
//         this.email = event.target.value;
//     } else if (field === 'gender') {
//         this.gender = event.target.value;
//     } else if (field === 'dob') {
//         this.dob = event.target.value;
//     } else if (field === 'searchQuery') {
//         this.searchQuery = event.target.value;
//     } else if (field === 'customObjectLookup') {
//         this.customObjectLookup = event.target.value;
//     } else if (field === 'duration') {
//         this.duration = event.target.value;
//         this.getDateAvailableSlot();
//     }
// }
@track formData = {
    memberName: '',
    memberGender: '',
    dob: '',
    address: '',
    telehealth: '',
    radius: '',
    email: '',
    careCategory: '',
    phone: '',
    appointmentType: '',
    timeZone: '',
    providerGender: '', // Added Provider Gender
    providerLanguage: '', // Added Provider Language
    provider: '' // Added Provider
};
selectedProviderId = '';

handleInputChange(event) {
    const fieldName = event.target.id; // Use the `id` attribute to identify the field
    const fieldValue = event.target.value; // Get the field value
    this.formData = { ...this.formData, [fieldName]: fieldValue }; // Dynamically update formData
    console.log('Updated Form Data:', this.formData['memberName-0']) ;
    console.log(' field name '+fieldName);
        if(fieldName == 'provider-0'){


            this.selectedProviderId = fieldValue;
            console.log(   this.selectedProviderId );
            getAvailableTimeSlots( { nextNDays: 7, providerID:  this.selectedProviderId   }).then(result=>{
      






                this.availableTimeSlots = result;








                this.initializeDate();
                this.generateDaysForCurrentMonth();
              
          
         const formattedDate = this.selectedDate.toISOString().split('T')[0];
         console.log(formattedDate); // Output: 2025-01-13
            this.selectedDate = formattedDate;
            this.filteredTimeSlots = [];
        
            this.filterTimeSlots();




            }).catch(error => {

                console.log(error);
            });
          
        }
                   
// For debugging
    console.log( JSON.stringify( this.formData));
}
getDateAvailableSlot(){
    //    if(this.duration == )

    let dateeTimeMap = new Map();

    this.availableSlots.forEach((timeMap, date) => {
        // console.log('okay'+JSON.stringify(timeMap));
        let filteredTimes = [];
        timeMap.forEach((r1,t2)=>{
            console.log(parseInt(r1,10)+' '+parseInt(this.duration,10));
                if(parseInt(r1,10)>=parseInt(this.duration,10)){
                    filteredTimes.push(t2);
                    console.log('t1'+date);
                    console.log('t2:'+t2+' '+r1);
                }
            
            // console.log('okay okay'+JSON.stringify(r1));
            // console.log('okay okay'+JSON.stringify(t2));
        });
        console.log('test '+filteredTimes);
        let times = Array.from(timeMap.keys());
        // console.log('okay okay'+JSON.stringify(times));
        // console.log('okay okay'+JSON.stringify(date));
        dateeTimeMap.set(date,filteredTimes);
        this.dateTimeMap = dateeTimeMap;


        let formattedDate = this.clickedFullDate.replace(/(\d{4})-(\d+)-(\d+)/, (_, year, month, day) => {
            return `${parseInt(month)}/${parseInt(day)}/${year}`;
        });
        
        let availableTimes = dateeTimeMap.get(formattedDate) || [];
        console.log('inside'+JSON.stringify(availableTimes));

    });
    // let formattedDate = this.clickedFullDate.replace(/(\d{4})-(\d{2})-(\d{2})/, '$2/$3/$1');
    let formattedDate = this.clickedFullDate.replace(/(\d{4})-(\d+)-(\d+)/, (_, year, month, day) => {
        return `${parseInt(month)}/${parseInt(day)}/${year}`;
    });
    console.log("date"+formattedDate);
    let availableTimes = this.dateTimeMap.get(formattedDate) || [];
    console.log('outside'+JSON.stringify(availableTimes));


    // console.log('Converted dateeTimeMap:', JSON.stringify(dateeTimeMap));
    

    // // @track dateTimeMap = new Map([

    // console.log('Converted :', JSON.stringify(this.dateTimeMap));
    // this.dateTimeMap = dateeTimeMap;
    // let formattedDate = this.clickedFullDate.replace(/(\d{4})-(\d{2})-(\d{2})/, '$2/$3/$1');
    // console.log("date"+formattedDate);
    //   let av = this.availableSlots[formattedDate];
    //   console.log("available"+JSON.stringify(av));

    


    // this.dateTimeMap.forEach((times, date) => {
    //     // console.log(`Date: ${date}`);
    //     // console.log('Times:', times);
        
    //     // If you want to log each time individually
    //     times.forEach(time => {
    //         // console.log(`Time: ${time}`);
    //     });
    // });
    this.setTimeOptions();
}

handleSearch() {
    // Logic for handling search action
    console.log('Search query:', this.searchQuery);
}

handleSubmit() {
    // Logic for handling form submission
    console.log('Form submitted with the following data:');
    console.log(`Patient Name: ${this.patientName}`);
    console.log(`Email: ${this.email}`);
    console.log(`Gender: ${this.gender}`);
    console.log(`Date of Birth: ${this.dob}`);
    console.log(`Search Query: ${this.searchQuery}`);
    console.log(`Custom Object Lookup: ${this.customObjectLookup}`);
    console.log(`Clinic Location Id for Lookup: ${this.closestClinicId}`);
    console.log(`Duration : ${this.duration}`);
  
    let dateParts = this.clickedFullDate.split('-');  // Split date into [YYYY, MM, DD]

    // Split time into [HH:mm] and [AM/PM]
    let timeParts = this.selectedTime.split(' ');  
    
    let time = timeParts[0];  // Time (e.g., '01:15')
    let period = timeParts[1];  // AM/PM (e.g., 'PM')
    
    // Split hours and minutes
    let [hours, minutes] = time.split(':');  
    
    // Convert 12-hour format to 24-hour format
    if (period === 'PM' && hours !== '12') {
        hours = (parseInt(hours) + 12).toString();  // Convert PM times except for 12 PM
    } else if (period === 'AM' && hours === '12') {
        hours = '00';  // Convert 12 AM to 00 (midnight)
    }
    
    // Format day and hour with leading zeroes if necessary
    let day = dateParts[2].padStart(2, '0'); // Ensures the day is always two digits
    let formattedHours = hours.padStart(2, '0'); // Ensures hours are always two digits
    let formattedMinutes = minutes.padStart(2, '0'); // Ensures minutes are always two digits
    
    // Construct the final formatted datetime
    let formattedDateTime = `${dateParts[0]}-${dateParts[1]}-${day}T${formattedHours}:${formattedMinutes}:00.000Z`;
    
   

    console.log(`Formatted DateTime: ${formattedDateTime}`);
    createAppointment({ 
        patientName: this.patientName, 
        email: this.email, 
        gender: this.gender, 
        dob: this.dob, 
        appointmentDateTime: formattedDateTime, 
        clinicLocationId: this.closestClinicId ,
        duration: this.duration  
    })
    .then(result => {
        console.log('Appointment created successfully with ID: ' + result);
        // You can navigate to a success page or show a success message
        this.navigateToSecondComponent();
    })
    .catch(error => {
        console.error('Error creating appointment: ', error);
        // You can handle the error, show an error message, etc.
    });

   
}
setClinicLocation(event){
    this.location = event.detail.value;
    console.log(this.location);
}
handleLocationSearchClick(){
    this.closestClinicId = 	"";
    this.searchLocation(this.location);
}
async searchLocation(originAddress) {
    try {
        const result = await retrieveClosestClinicLocationId({ originAddress: originAddress });
        this.closestClinicId = result;
        console.log('result-->', this.closestClinicId);
        try {
            // this.clinicLocation = await getClinicLocationNameById({ clinicLocationId: this.closestClinicId });
            // this.clinicName = this.clinicLocation; 
            // this.clinicName1=true;
            // console.log('Clinic Location:', this.clinicLocation);
            // this.ClinickNotFoundMsg = '';  
             // Call the updated Apex method to fetch both Name and Address
             const clinicData = await getClinicLocationNameById({ clinicLocationId: this.closestClinicId });

             if (clinicData) {
                 // Extract clinic name and address from the result
                 this.clinicName = clinicData.Name;
                 this.clinicAddress = clinicData.Address; // Get the address
                 this.clinicName1 = true;
 
                 console.log('Clinic Location:', this.clinicName);
                 console.log('Clinic Address:', this.clinicAddress);
                 this.ClinickNotFoundMsg = '';  
             } else {
                 // Handle case where clinic data is not found
                 this.clinicName = ''; 
                 this.clinicAddress = '';
                 this.clinicName1 = false;
                 this.ClinickNotFoundMsg = "Clinic not found with this location";
             }

        } catch (error) {
            console.error('Error fetching closest clinic:', error);
            this.clinicName = ''; // Clear clinic data if main lookup fails
            this.clinicAddress = '';
            this.ClinickNotFoundMsg = "Error fetching closest clinic";  // Set error message
        }
       
        
        if (this.closestClinicId == null) {
            this.clinicName = ''; 
            this.clinicAddress = '';
            this.clinicName1=false;
            this.ClinickNotFoundMsg = "Clinic not found with this location"
        } else {
            // this.ClinickNotFoundMsg = "";

        }
        // this.spinner = false;

        // this.activeTab = '2'

    } catch (error) {
        console.error('Error fetching closest clinic:', error);
        // this.spinner = false;
    }
    // this.closestClinicId = 	
    // 'a1OWr000000NSgLMAW';
}
handleClosestclinic(event){
    this.closestClinicId = event.detail.value;
    
}
navigateToSecondComponent() {
    // Navigate to the second component
    // console.log("pp");
    // this[NavigationMixin.Navigate]({
    //     type: 'standard__component',
    //     attributes: {
    //         componentName: 'c__appointmentSubmitSuccess' // Ensure this matches the API name of your second component
    //     }
    // });
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






}