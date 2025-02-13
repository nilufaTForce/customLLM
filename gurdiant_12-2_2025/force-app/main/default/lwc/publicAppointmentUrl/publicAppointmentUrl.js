import { LightningElement,track  } from 'lwc';
import retrieveClosestClinicLocationId from '@salesforce/apex/DistanceService.getClosestClinicLocationId';
import getClinicLocationNameById from '@salesforce/apex/DistanceService.getClinicLocationNameById';
import getAvailableSlots from '@salesforce/apex/GuardiantUtility.getAvailableAppointmentSlots';
// import createAppointment from '@salesforce/apex/PatientFormController.createAppointment';
import { NavigationMixin } from 'lightning/navigation';
export default class PublicAppointmentUrl extends NavigationMixin(LightningElement) {


@track weeks = ['Sun', 'Mon','Tue', 'Wed', 'Thu','Fri','Sat'];
@track clinicName = '';  // To store the clinic name
@track clinicName1 = false; 
@track ClinickNotFoundMsg = '';  // To store a message when no clinic is found
@track availableSlots ;

@track days = []
selectedMonth = '';
 selectedYear = '';
 selectedDay = '';
 selectedDate = '';
 clickedDay ='';
 @track clickedFullDate = 'Select a Date';
 @track availableTimes = [];
 @track timeOptions = [];
 @track selectedTime = '15 minutes';
 thisDay ;

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
@track tempTimeOptions =[];




connectedCallback() {

   let dateeTimeMap = new Map();
    getAvailableSlots()
    .then((result) => {

        this.availableSlots = new Map(
            Object.entries(result).map(([date, timesObj]) => [
                date,
                new Map(Object.entries(timesObj))
            ])
        );

        let dateeTimeMap = new Map();

        this.availableSlots.forEach((timeMap, date) => {

            console.log('i m date'+JSON.stringify(date));
            timeMap.forEach((r1,t2)=>{

                console.log('d1'+JSON.stringify(r1));
                console.log('d2'+JSON.stringify(t2));
            })
            let times = Array.from(timeMap.keys());
            console.log('okay okay'+JSON.stringify(times));
            console.log('okay okay'+JSON.stringify(date));
            dateeTimeMap.set(date, times);
        });

        console.log('Converted dateeTimeMap:', JSON.stringify(dateeTimeMap));
        

        // @track dateTimeMap = new Map([

        console.log('Converted :', JSON.stringify(this.dateTimeMap));
        this.dateTimeMap = dateeTimeMap;
        this.dateTimeMap.forEach((times, date) => {
            console.log(`Date: ${date}`);
            // console.log('Times:', times);
            
            // If you want to log each time individually
            times.forEach(time => {
                console.log(`Time: ${time}`);
            });
        });
        // // this.availableSlots = result; // Set the data to the tracked property
        // // console.log('Available Slots:', JSON.stringify(this.availableSlots));

        // this.availableSlots.forEach((timeMap,date) => {
        // //   console.log
        //     // let times = Array.from(timeMap.keys()); 
         
        //     // dateeTimeMap.set(date, times);
        // });
        // console.log('eeeeeeeeeeeeeeeeeeeeeeeeeee'+dateeTimeMap);
        this.initializeDate();
        this.generateDaysForCurrentMonth();
       console.log('connected call back');
    })
    .catch((error) => {
        this.error = error; // Capture and log any error
        console.error('Error fetching available slots:', error);
    });   
}


//calender code starts
initializeDate() {
    const currentDate = new Date();
    this.selectedDate = currentDate;
    this.selectedYear = currentDate.getFullYear();
    this.selectedMonth = currentDate.toLocaleString('default', { month: 'short' });
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
      
           if(!pastDay && !today){
            today = true;
          this.thisDay = day;
            this.days.push({
                day: day,
                isPast: pastDay,
                isToday:true
            });
           }else{
            this.days.push({
                day: day,
                isPast: pastDay,
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
    let formattedDate = date.replace(/(\d{4})-(\d{2})-(\d{2})/, '$2/$3/$1');
    this.availableTimes = this.dateTimeMap.get(formattedDate) || [];

    console.log( "hummm"+JSON.stringify(this.availableTimes ));

    this.setTimeOptions();


}
setTimeOptions() {
    
  let formattedDate = this.clickedFullDate.replace(/(\d{4})-(\d+)-(\d+)/, (_, year, month, day) => {
    return `${parseInt(month)}/${parseInt(day)}/${year}`;
});

  this.availableTimes = this.dateTimeMap.get(formattedDate) || [];

  this.timeOptions = this.availableTimes.map(time => {
    if(parseInt(time,10)>12){
        time = parseInt(time, 10) - 12;
        console.log(time);
        time = time + ":00 PM";
    }else{
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
    this.selectedMonth = date.toLocaleString('default', { month: 'short' });
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
    let formattedDate = date.replace(/(\d{4})-(\d+)-(\d+)/, (_, year, month, day) => {
        return `${parseInt(month)}/${parseInt(day)}/${year}`;
    });
    
    console.log("oo"+formattedDate);
    const availableTimes = this.dateTimeMap.get(formattedDate) || [];

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

handleInputChange(event) {
    const field = event.target.dataset.id;
    if (field === 'patientName') {
        this.patientName = event.target.value;
    } else if (field === 'email') {
        this.email = event.target.value;
    } else if (field === 'gender') {
        this.gender = event.target.value;
    } else if (field === 'dob') {
        this.dob = event.target.value;
    } else if (field === 'searchQuery') {
        this.searchQuery = event.target.value;
    } else if (field === 'customObjectLookup') {
        this.customObjectLookup = event.target.value;
    } else if (field === 'duration') {
        this.duration = event.target.value;
        this.getDateAvailableSlot();
    }
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


}