import Foundation
import CoreLocation

struct Program: Codable, Equatable, Identifiable {
    let id: UUID
    let link: String
    let name: String
    let location: String
    let category: String
    let selectivity: String
    let applicationDate: String
    let duration: String
    let restrictions: String
    let cost: String
    let latitude: Double
    let longitude: Double
    let likeSkip: Bool
    
    // Computed property for coordinates (CLLocationCoordinate2D isn't Codable)
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Custom init to generate UUID
    init(link: String, name: String, location: String, category: String,
         selectivity: String, applicationDate: String, duration: String,
         restrictions: String, cost: String, latitude: Double, longitude: Double,
         likeSkip: Bool, id: UUID = UUID()) {
        self.id = id
        self.link = link
        self.name = name
        self.location = location
        self.category = category
        self.selectivity = selectivity
        self.applicationDate = applicationDate
        self.duration = duration
        self.restrictions = restrictions
        self.cost = cost
        self.latitude = latitude
        self.longitude = longitude
        self.likeSkip = likeSkip
    }
}
func parseCSVData() -> [Program] {
    /*
    data scraped legally from the following URLS
     
     "http://www.summitadmissionsconsulting.com/stem.html",
     "http://www.summitadmissionsconsulting.com/humanities.html",
     "http://www.summitadmissionsconsulting.com/art-architecture--design.html",
     "http://www.summitadmissionsconsulting.com/business--entrepreneurship.html"
     
     longitude and latitude manually found
     */
    let csvContent = """
   LINK,PROGRAM,LOCATION,CATEGORY,SELECTIVITY,APPLICATION DATE,DURATION,RESTRICTIONS,COST,LATITUDE,LONGITUDE
   https://beaverworks.ll.mit.edu/CMS/bw/BWSI,BeaverWorks Summer Institute,MIT,"Engineering, CS, AI, Robotics",N/A,See website,4 weeks,Rising Seniors Only,"Tuition + Room & Board $5,000",42.3601,-71.0942
   https://www.bu.edu/summer/high-school-programs/rise-internship-practicum/,BU RISE,Boston University,All STEM categories,6% (130/800),February 14,6 weeks,Rising Seniors,$4650 tuition Room & ​Board $2994,42.3505,-71.1054
   http://www.depts.ttu.edu/honors/academicsandenrichment/affiliatedandhighschool/clarks/,Clark Scholars,Texas Tech,Every Major,12 students only,February 10,7 weeks,17 years +,$750 stipend + Room & Board,33.5843,-101.8783
   https://www.stonybrook.edu/commcms/garcia/summer_program/program_description.php,The Garcia Program REU,Stony Brook University,Polymer Research,N/A,February 24,7 weeks,16 +,Lab Fees $2700​Room & Board additional costs,40.9124,-73.1234
   https://www.usaeop.com/program/seap/,Science and Engineering Apprenticeship Program (SEAP),"Playa Vista, CA (Dept. of Defense) + Out of State","Data, STEM",N/A,February 28,,16 +. Rising Juniors / Seniors,StipendRoom & Board N/A,33.9777,-118.4230
   https://www.usaeop.com/program/hsap/,High School Apprenticeship Program (HSAP),USC (Army / Dept. of Defense),STEM Research,N/A,February 28,8 - 10 weeks,Rising Juniors / Seniors,Stipend,34.0224,-118.2851
   http://education.msu.edu/hshsp/program-information/#application-information,"High School Honors Science, Math and Engineering Program (HSHSP)",Michigan State,All STEM,24~,March 1,7 weeks,Rising seniors,"$3,800",42.7325,-84.5555
   http://med.stanford.edu/genecamp/process.html,Genomics Research Internship Program (GRIP),Stanford,"Genomics, CS",N/A,March 2,8 weeks,16+ / Bay Area HS,Free,37.4275,-122.1697
   https://research.princeton.edu/about-us/internships/laboratory-learning-program,Laboratory Learning Program,Princeton,Engineering + Natural Science Research,N/A,March 15,5 - 6 weeks,16 +,Free (Room & Board N/A),40.3430,-74.6514
   https://www.ll.mit.edu/outreach/llrise,Lincoln Laboratory Radar Introduction for Student Engineers (LLRISE),MIT,Radar Systems,N/A,,2 weeks,Rising senior,Free (Room & Board included),42.3601,-71.0942
   No Link,The Science and Engineering Apprenticeship Program (SEAP),Multiple US Navy + Dept. of Defense Labs,STEM,250,Nov 1,8 weeks,9+,$3500 stipend No Housing,38.9072,-77.0369
   http://www.tsgc.utexas.edu/sees-internship/,Stem Enhancement in Earth Science (SEES),NASA @ UT Austin,Earth / Space research,11% (45/500),February 22,2 weeks,Rising junior / senior,FREE: Tuition + Room & Board,30.2849,-97.7341
   https://www.stonybrook.edu/simons/,Simons Summer Research Program,Stony Brook University,Multiple STEM,8%,January 22,5 weeks,Rising senior,$3200 Residential,40.9124,-73.1234
   https://summerscience.org,Summer Science Program (SSP),Multiple,"Astrophysics, Biochemistry",10%,February 28,5 weeks,Rising seniors,Heavy Financial Aid,34.4208,-119.6982
   https://www.cpet.ufl.edu/students/summer-programs/student-science-training-program/,Student Science Training Program (SSTP),"U Florida, Gainesville, FL",Multiple research,accepts 90 students,Dec - Feb (rolling) March 1 (priority),7 weeks,Rising senior,$4800 (including housing),29.6436,-82.3549
   http://simr.stanford.edu,Stanford Institutes of Medicine Summer Research Program (SIMR),"Stanford, CA",Biomedical (multiple research labs),accepts 50 students,February 23,8 weeks,juniors / seniors,$500 minimum stipend,37.4275,-122.1697
   https://www.cee.org/apply-rsi,Research Science Institute (RSI),MIT,STEM,accepts 80 students,January 15,7 weeks,Rising seniors,Cost-Free (includes residential),42.3601,-71.0942
   http://ucsc-sip.org,Science Internship Project (SIP),UC Santa Cruz,Multiple STEM,Accepts 165 students,March 21,8-10 weeks,14+ (favors rising seniors),$3300 tuition (non-residential),36.9914,-122.0583
   http://wtp.mit.edu,Women's Technology Program (WTP),MIT,EECS or ME (Mechanical),11% (60/700),January 15,4 weeks,Rising seniors (favors underserved),$3500 maximum,42.3601,-71.0942
   https://perimeterinstitute.ca/outreach/students/programs/international-summer-school-young-physicists,International Summer School for Young Physicists (ISSYP),"Waterloo, Ontario, Canada",Physics,Accepts 20 Canadian / 20 Int'l,March 25,2 weeks,junior / senior,$500 Canadian,43.4643,-80.5204
   https://yspa.yale.edu,Yale Program in Astrophysics (YSPA),Yale U,Astrophysics + STEM,Accepts 32 students,,2 week online + 4 week residential,Rising senior,$6100 (Tuition + Residential),41.3163,-72.9223
   https://education.ucdavis.edu/ysp-about,Young Scholars Program (YSP),UC Davis,Natural Sciences,10% - 12% Accepts 40 students,March 16,6 weeks,10 - 12,"$6,500 tuition + residential",38.5382,-121.7617
   https://belinblank.education.uiowa.edu/students/sstp/#how-to-apply,SSTP (Secondary Student Training Program),U Iowa,Multiple STEM,N/A,January 10,5 weeks,Rising junior / senior,"$6,395 (Tuition + Residential)",41.6611,-91.5302
   https://earth.stanford.edu/academics/young-investigators,Stanford Young Earth Investigators,Stanford,Earth Sciences,0.04% (7/150 accepted in 2019),March 15,7 weeks,Rising 10th-12th + 25~ miles to Stanford,Free,37.4275,-122.1697
   https://plasticsurgery.stanford.edu/education/stars/Apply.html,"Science, Technology, and Reconstructive Surgery (STaRS) Summer Internship Program",Stanford,Medicine,N/A,January 21,7 weeks,16+,N/A,37.4275,-122.1697
   https://apps.carleton.edu/summer/humanities/,Engineering Summer Program (ESP),U Wisconsin,Engineering,N/A,April 6,6 weeks,,Free,43.0074,-89.4012
   https://sparc-camp.org,Summer Program on Applied Rationality and Cognition -- SPARC,CSU East Bay,"Modeling, probability, game theory, cognitive science, quantitative reasoning",30~ admitted annually,February 15,2 weeks,14+,Free tuition / housing,37.6554,-122.0574
   https://cosmos-ucop.ucdavis.edu/app/main/,COSMOS,"UCSC, UC Davis, UC Irvine, UCSD",Multiple STEM,Varies by campus/cluster,February 7,4 weeks,N/A,$4128 (in-state),38.5382,-121.7617
   http://med.stanford.edu/cssec/summer-internship.html#application-faqs,Cardiothoracic Surgical Skills Summer Internship,Stanford,Medicine / Public Health,N/A,TBD,2 weeks,16+,"Tuition: $5,995Housing: $3,995",37.4275,-122.1697
   https://sce.cornell.edu/precollege/program/bio-research,Research Apprenticeship in Biological Sciences (RABS),Cornell,Biology,N/A,Rolling (for top lab placement),6 weeks,Rising juniors / seniors,$13500,42.4534,-76.4735
   https://www.summer.ucsb.edu/pre-college/research-mentorship-program-rmp,Research Mentorship Program (RMP),UC Santa Barbara,Multiple STEM,N/A,March 15 (rolling),6 weeks,Rising junior / senior (will consider rising 10th),"$10,499 (residential + tuition)",34.4140,-119.8489
   https://summer.uchicago.edu/programs/research-biological-sciences-ribs,Research in the Biological Sciences (RIBS),U Chicago,Biology,N/A,January 22 (priority)​February 26 (regular),4 weeks,Rising juniors / seniors,"$12,200 (residential + tuition)",41.7886,-87.5987
   http://med.stanford.edu/medcsi/application.html,Stanford Clinical Science Internship (CSI),Stanford,Medicine,N/A,February 17,2 weeks,16+ (rising juniors / seniors),"$5,385",37.4275,-122.1697
   https://stanfordaimlab.slideroom.com/#/login,"Clinical Science, Technology & Medicine Internship",Stanford,Medicine,N/A (Advanced Program far more selective),Early: Dec. 23​Regular: Feb. 14,2 weeks,N/A,N/A,37.4275,-122.1697
   https://www.med.stanford.edu/shvca.html,Stanford ValleyCare Clinical Academy Program,Stanford,Medicine,N/A,February 24,2 weeks,16+ (rising juniors / seniors),$3500,37.4275,-122.1697
   https://med.stanford.edu/genecamp/SBCCW.html,BCCW (Bioinformatics Cloud Computing Workshop),Stanford,Bioinformatics + Cloud Computing,N/A,Rolling (opens January),3 weeks,16+​Rising seniors + current seniors,"$5000 (tuition) ​$8,000 (tuition + residential)​",37.4275,-122.1697
   https://globalscholars.yale.edu,Yale Young Global Scholars (YYGS),Yale U,Applied Science & Engineering / Biological & Biomedical,N/A,EA November 12Regular January 15​(Rolling),2 weeks,16+ ​Rising junior / senior,"$6,300 (tuition + residential)",41.3163,-72.9223
   https://researchscholars.ucsd.edu/apply/index.html,UCSD Research Scholars Program,UCSD,Multiple (Bioengineering / Molecular Bio / Sports Medicine),N/A,February 14 - 21,1 - 6 weeks,High school,Varies,32.8801,-117.2340
   https://universitycollege.tufts.edu/high-school/programs/tufts-summer-research-experience,Tufts Summer Research Experience,Tufts U,Multiple STEM,N/A,12/1 - 5/1 open​Rolling,6 weeks,Rising junior / senior,"$11,250 (tuition + residential)",42.4085,-71.1183
   https://www.umass.edu/summer/programs/research-intensive-labs,UMass Research Intensive Labs,"Amherst, MA","Biology, Biochemistry, Astronomy, Psychology",N/A,Confirm w/ website,6 weeks,Rising 10 - 12,"$10,185 (includes 6 academic credits)",42.3868,-72.5301
   https://www.nyu.edu/admissions/high-school-programs/nyu-gstem.html,NYU GSTEM,NYU,Computer Science,N/A,EA March 15​Regular April 15,6 weeks,Rising 12 (prefers girls/minorities),$4500 tuition ​Housing available,40.7295,-73.9965
   https://bluestampengineering.com,Bluestamp Engineering,"Multiple (Palo Alto, SF, NYC)","Engineering, Robotics, CS",N/A,Rolling,6 weeks (flexible),High school (including rising 9th),"$4,200 (commuter only)",37.4419,-122.1430
   https://sce.cornell.edu/precollege/program/engineering,Cornell Engineering Experience,Cornell,Engineering (broad overview),N/A,Rolling,6 weeks,Juniors / Seniors,"$13,500 (tuition + residential)",42.4534,-76.4735
   https://esap.seas.upenn.edu/apply/,Engineering Summer Academy at Penn (ESAP),UPenn,Engineering,N/A,March 1 (priority)​April 5 (regular),3 weeks,"Rising 10th, 11th, 12th","$7,690",39.9522,-75.1932
   https://ei.jhu.edu/about-ei/what-is-ei/,Johns Hopkins Engineering Innovation (EI),Multiple (Johns Hopkins),Engineering,,Rolling,4-5 weeks,Rising junior / senior (will consider 9th/10th),"$7,500 (tuition + residential)",39.3299,-76.6205
   https://www.cmu.edu/pre-college/academic-programs/computational-biology.html,CMU Computational Biology,Carnegie Mellon U,Computational biology,N/A,March 1 (priority)March 15 (regular)​rolling,3 weeks,Varies,"$6,099",40.4433,-79.9436
   https://jkcp.com/program/penn-medicine-summer-program-for-high-school-students/,Penn Medicine Summer Program,UPenn,Medicine,N/A,March 4,4 weeks,Rising juniors / seniors,"$8,495 (tuition + residential)",39.9522,-75.1932
   https://summer.uchicago.edu/programs/stones-and-bones,U Chicago Stones & Bones,U Chicago / fieldwork,Paleontology,N/A,January 22 (priority)February 26 (regular),4 weeks,9 - 12,"$11,900",41.7886,-87.5987
   http://med.stanford.edu/psychiatry/special-initiatives/CNIX.html,Clinical Neuroscience Immersion Experience      (CNI-X),Stanford,Neuroscience,N/A,Rolling,1 or 2 week sessions,9 - 12,$1295 (1 week)$2500 (2 week),37.4275,-122.1697
   https://www.fremontstem.org/asdrp,Aspiring Scholars Directed Research Program (ASDRP),"Fremont, CA",STEM (multiple),N/A,,6/13 - 8/23,Rising 9 - 12,$850 (commute),37.5485,-121.9886
   https://engineering.nyu.edu/research-innovation/k12-stem-education/tandon-summer-programs/machine-learning,NYU Machine Learning,NYU,Machine Learning,N/A,Priority Feb 28 Regular March 14,2 weeks,9 - 12,$2000 tuition + $1000~ residential,40.7295,-73.9965
   https://www.tellurideassociation.org/our-programs/high-school-students/summer-program-juniors-tasp/,TASP (Telluride Association Summer Program) ,Multiple (Cornell / U Maryland / U Michigan,Humanities,Extreme (sample application pdf),January 13,6 weeks,Rising 12,Free,42.4534,-76.4735
   https://summerhumanities.spcs.stanford.edu,Stanford Humanities Institute (SHI) ,Stanford U,Multiple Humanities,Difficult,January 29 EAFebruary 26 RD,3 weeks,Rising 11 - 12,"$7,100",37.4275,-122.1697
   https://globalscholars.yale.edu/our-program,YYGS (Yale Young Global Scholars),Yale U,Multiple,Difficult (6500 applications),November 12 EA​January 15 RD,2 weeks,Rising 10 - 12      (16 minimum),$6300,41.3163,-72.9223
   https://www.tellurideassociation.org/our-programs/high-school-students/sophomore-seminar-tass/,TASS (Telluride Association Sophomore Seminar),"Cornell, U Mich",Ethnic Studies,Difficult (56 max) * application pdf,January 6,6 weeks,Current 10,Free,42.4534,-76.4735
   https://apps.carleton.edu/summer/humanities/,Summer Humanities Institute (SHI),Carlton,Humanities,Moderate,February 14 R1March 16 R2,3 weeks,Current 10 - 11,$3900,44.4616,-93.1537
   https://www.experiment.org/program-landing/themes/lead-development/,The Experiment Leadership Institute,D.C. / International,Leadership / Global Issues,Difficult (15 annual),January 15,1 month,Rising seniors,100% Scholarship,38.9072,-77.0369
   https://www.yiddishbookcenter.org/educational-programs/great-jewish-books-summer-program/faq,Great Jewish Books Summer Program,"Hampshire,",Literature,Difficult,March 9,1 week,Rising 11 - 12,100% scholarship,42.3255,-72.6732
   https://www.medill.northwestern.edu/journalism/high-school-programs/medill-cherubs.html,Medill Cherubs ,Northwestern U,Journalism,Under 50% accepted​84 annually,March 16,5 weeks,Rising 12th,"$6,100 residential + tuition",42.0565,-87.6753
   https://newsroombythebay.com,Newsroom by the Bay,Stanford,Journalism,Unknown,Rolling,2 weeks,9 - 12,$4750 residential$2500 commuter,37.4275,-122.1697
   http://www.cvent.com/events/cspa-summer-journalism-workshop-2020/event-summary-983a73005492431aae44e78aade3d47a.aspx,CSPA Summer Journalism Workshop,Columbia U,Journalism,Not selective200 accepted annually,Rolling,1 week,Rising 10 - 12,$1500 residential,40.8075,-73.9626
   https://combeyond.bu.edu/workshop/bu-summer-journalism-institute/,Boston U Summer Journalism Workshop,Boston U,Journalism,Slightly selective,Rolling until June 1,2 weeks~,Ages 15 - 18,$3500 residential,42.3505,-71.1054
   https://www.emerson.edu/majors-programs/pre-college-programs/journalism,Pre-College Journalism @ Emerson,Emerson U (Boston),Journalism,Slightly selective,Priority: Feb 1Final: May 1,3 weeks,Rising 10 - 12,Tuition: $3354 + Residential $1848,42.3521,-71.0659
   https://iyws.clas.uiowa.edu,Iowa Young Writers' Studio ,"U of Iowa (Iowa City, IA",Creative Writing,Difficult,February 7,2 weeks,Rising 11 - 12 (rare exceptions),$2400 tuition + residential,41.6611,-91.5302
   https://college.lclark.edu/programs/fir_acres/,Fir Acres Writing Workshop,"Lewis & Clark, Portland​, OR",Creative Writing,Easy - Moderate,March 9,2 weeks,Rising 10 - 12,$3250 - residential + tuition,45.4501,-122.6699
   https://camp.interlochen.org,Interlochen Arts Camp,"Interlochen, MI",Novel Writing​TV Writing + 3-week creative writing,Moderate,January 15 (portfolio) / ​Rolling,1 week ​3 weeks,9 - 12,See website,44.6333,-85.7686
   http://www.umass.edu/juniperyoungwriters/#/,Juniper Institute for Young Writers,"UMass ​Amherst, MA",Creative Writing,Easy - Moderate,Priority Nov. 25 ​Rolling,1 week,Rising 10 - 12,$2000 tuition + residential,42.3868,-72.5301
   https://www.csssa.ca.gov,CSSSA (CA State Summer School for the Arts) ,"Davis, CA",Creative Writing,Difficult (70 annual),February 12,1 month,9 - 12,$2250 CA residents / $6750 out-of-state,38.5382,-121.7617
   http://sites.middlebury.edu/neywc/,New England Young Writers' Conference,"Middlebury College, VT",Creative Writing,Moderate - Difficult,December 5,4 days,Rising 12,$385 (tuition + residential),44.0092,-73.1755
   http://writing.upenn.edu/wh/summer/,Summer Workshop for Young Writers @ The Kelly Writers House,UPenn,Creative Writing,Moderate - Difficult,March 8,2 weeks,Rising 11 - 12,$2750 residential + tuition,39.9522,-75.1932
   http://www.sewanee.edu/sywc/,Sewanee Young Writers Conference,"Sewanee, TN",Creative Writing,Easy - Moderate,Feb 22 ​ Rolling,2 weeks,9 - 11,$2400 tuition + residential,35.2037,-85.9218
   https://tisch.nyu.edu/special-programs/high-school-programs/dramatic-writing,NYU Tisch Summer High School Dramatic Writing,NYU,Creative Writing,Moderate - Difficult (40% approximate),January 23,1 month,Rising 11 - 12,See website,40.7295,-73.9965
   https://www.smith.edu/academics/precollege-programs/writing,Creative Writing Workshop,"Smith College (Northampton, MA)",Creative Writing,Easy,March 1 Early Decision / Rolling,2 weeks,Rising 9 - 12 female students,$3385 residential + tuition,42.3184,-72.6408
   https://kenyonreview.org/workshops/young-writers/,The Young Writers Workshop @ Kenyon Review,"Kenyon College, OH",Creative Writing,"Moderate" ,March 1,2 weeks,16 - 18,$2475 residential + tuition,40.3756,-82.3971
   https://summer.uchicago.edu/course/creative-writing,U Chicago Creative Writing Immersion,U Chicago,Creative Writing,Easy,,3 weeks,9 - 11,$7300 tuition + residential,41.7886,-87.5987
   https://launchx.com,Launch X Young Entrepreneurs Program,MITNorthwestern​U Michigan​UPenn,EntrepreneurshipBusiness,18%,EA December 15RD February 1 ​Rolling,4 weeks,9 - 12,Confirm w/ website,42.3601,-71.0942
   https://globalyouth.wharton.upenn.edu/summer-high-school-programs/leadership-in-the-business-world/,Leadership in the Business World - LBW,UPenn,Entrepeneurship ​Business,160 (2 sections),Priority: January 22​,1 month,Rising 11 - 12,$8495,39.9522,-75.1932
   https://fisher.wharton.upenn.edu/management-technology-summer-institute/,Management & Technology Summer Institute,UPenn,Entrepreneurship​Tech,50 - 75 annually,February 1,3 weeks,Rising 12 +exceptional Rising 11,$7500,39.9522,-75.1932
   https://www.babson.edu/admission/visiting-student-programs/babson-summer-study/,Babson Summer Study,"Babson College (Boston, MA)",Entrepreneurship,Moderate,March 9,4 weeks,Rising 11 - 12,$8750,42.2999,-71.2662
   https://www.stern.nyu.edu/programs-admissions/undergraduate/high-school-summer-program,Summer @ Stern,NYU,,Moderate,March 2 Part 1March 20 Part 2,6 weeks,Rising 11 -12,Confirm w/ website,40.7295,-73.9965
   https://haas.berkeley.edu/business-academy/high-school-entrepreneurship/,B-BAY​High School Entrepreneurship,UC Berkeley Haas,Entrepreneurship,50 annually,RollingApril 15 Final,2 weeks,High School,$5700,37.8719,-122.2585
   https://summer.uchicago.edu/course/pathways-leadership-and-entrepreneurship,Pathways in Leadership & Entrepreneurship,U Chicago,Entrepreneurship,Easy - Moderate,Priority Jan 22Regular Feb 26Extended April 1Rolling post 4/1,3 weeks,High School,$7100,41.7886,-87.5987
   https://sce.cornell.edu/precollege/program/business-world,The Business World,Cornell,Business / Economics / Entrepreneurship,Moderate,May 1 ​Rolling,3 weeks,10 - 12,$6710,42.4534,-76.4735
   https://www.mccombs.utexas.edu/BBA/Academics/Summer-High-School-Programs,McCombs Summer High School Programs,UT Austin,Business / Entrepreneurship,Moderate,January 31 PriorityApril 1 Regular,1 week,Rising 11 - 12,Free,30.2849,-97.7341
   https://wsb.wharton.upenn.edu/students/moneyball-academy/,Wharton Moneyball Academy,UPenn,Sports Analytics ​Statistics,Easy - Moderate,Priority January 22,3 weeks,Rising 10 - 12,Confirm w/ website,39.9522,-75.1932
   https://artofproblemsolving.com/wiki/index.php/Mathematical_Olympiad_Summer_Program,Mathematical Olympiad Summer Program​ MOP ,Carnegie Mellon U,Mathematics,,USAMO,3 weeks,Top 12 finishers on USAMO,Free,40.4433,-79.9436
   https://www.mathcamp.org,Mathcamp ,"Burlington, VT",March 12,,,,13 - 18,$4500,44.4759,-73.2121
   http://www.math.unl.edu/programs/agam,All Girls / All Math,U Nebraska,Mathematics,,March 2,1 week,Rising 10 - 12​30 accepted annual,2 tier pricing: ​1) $1000 2) ​$500,40.8202,-96.7005
   https://www.awesomemath.org,AwesomeMath,Multiple US campuses,Mathematics,,,3 weeks,,,40.4433,-79.9436
   https://hcssim.org,The Hampshire College Summer Studies in MathematicsHCSSiM,Hampshire College,Mathematics,,Rolling,6 weeks,High School,$4193 residential + tuition,42.3255,-72.6732
   https://www.txstate.edu/mathworks/camps/Summer-Math-Camps-Information/hsmc/Honors-Summer-Math-Camp-Information-.html,Honors Summer Math Camp (HSMC),"Texas State ​(San Marcos, TX)",Mathematics,,Rolling​: Round 1 Feb 15 Round 2 March 15 Round 3 April 15,6 weeks,Rising 10 - 12 ​(20% accepted),$4800,29.8883,-97.9403
   http://www.mathily.org,MathILY,Bryn Mawr,Mathematics,,Rolling until April 28,5 weeks,High School,$4800,40.0189,-75.3143
   https://promys.org,Program for Mathematics for Young Scientists PROMYS,Boston U,Mathematics,,March 15,6 weeks,14 - 19​Rising 10+,$5150,42.3505,-71.1054
   https://rossprogram.org,Ross Mathematics Program,The Ohio State U,Mathematics,,Rolling until April 1,6 weeks,High SchoolUnder 30% accepted,$5000,40.0067,-83.0305
   https://www.math.tamu.edu/outreach/Camp/,Summer Mathematics Research TrainingHigh School Camp SMaRT,Texas A&M U,Mathematics,,March 15,2 weeks,14 - 18,Free,30.6187,-96.3365
   https://sumac.spcs.stanford.edu,Stanford U Mathematics Camp (SuMAC),Stanford U,Mathematics,,March 11,4 weeks,Rising 11 - 12,$7000,37.4275,-122.1697
   https://sparc-camp.org,Summer Program on Applied Rationality and Cognition (SPARC),"CSU East Bay, CA",Mathematics,,February 15,2 weeks,High School (14+)​30 accepted,Free,37.6554,-122.0574
   https://proveitmath.org/eligibility/,Prove It! Math Academy,"Colorado State U​Fort Collin, CO",Mathematics,,March 15,2 weeks,High School (14+)held alternate years,$3291,40.5853,-105.0844
   https://summer.ucla.edu/institutes/GameLab,UCLA Game Lab Summer Institute,UCLA,Game Design,,May 1,2 weeks,9 - 12 (non-competitive),$2310 tuition + $1224 residential​,34.0689,-118.4452
   https://comartsci.msu.edu/camps,MSU Media Camp Game Design,Michigan State U,Game Design,,Confirm with website,2 weeks,High School (non-competitive),$2250 residential + tuition,42.7325,-84.5555
   https://www.cmu.edu/pre-college/academic-programs/game-academy.html,National High School Game Academy (NHSGA),Carnegie Mellon U,Game Design,,Rolling,6 weeks,16+,$9668 tuition + residential,40.4433,-79.9436
   https://tisch.nyu.edu/special-programs/high-school-programs/game-design,Tisch Summer High School Game Design,NYU,Game Design,,January (confirm w/ website),4 weeks,Rising juniors / seniors,$12113 residential + tuition,40.7295,-73.9965
   https://cosmos.ucsc.edu/clusters/c5.html,Video Game Design @ COSMOS,UCSC,Game Design,,February 7,4 weeks,High School,"$4,128 residential + tuition",36.9914,-122.0583
   https://www.idtech.com/id-game-dev-academy,Game Dev Academy (ID Tech Camp),Multiple,Game Design,,Rolling,2 weeks,High School,Confirm w/ website,37.7749,-122.4194
   https://vetsites.tufts.edu/avm/,Adventures in Veterinary Medicine,Tufts U,Veterinary Medicine,,,2 weeks (2 sections),Rising 10 - 12,$3850 (residential + tuition),42.4085,-71.1183
   https://sce.cornell.edu/precollege/program#,Veterinary Medicine (Conservation + Small Animals),Cornell U,Veterinary Medicine,,May 1 (Rolling),3 weeks,Juniors / Seniors,"$6,750 (residential + tuition)",42.4534,-76.4735
   https://vet.uga.edu/education/k-12-programs/vetcamp/,VetCAMP (Veterinary Career Aptitude and Mentoring Program),U of Georgia,Veterinary Medicine,,January 24,1 week,10 - 12,$900 (residential / tuition),33.9519,-83.3576
   https://www.purdue.edu/vet/boilervetcamp/index.php,Boiler Vet Camp,Purdue U,Veterinary Medicine,,February 3,1 week,Rising 10 - 12,$1500,40.4237,-86.9212
   http://auburn.edu/outreach/opce/auburnyouthprograms/vetcamp.htm,Senior Vet Camp,Auburn U,Veterinary Medicine,,February 2,1 week,Rising 9 - 12,$845 (Residential / Tuition),32.6010,-85.4877
   https://bims.tamu.edu/future/veterinary-enrichment-camp/,Veterinary Enrichment Camp,Texas A&M,Veterinary Medicine,,January 17,1 week,Rising 11 - 12,$600 (residential / tuition),30.6187,-96.3365
   https://vetmed.oregonstate.edu/osu-summer-veterinary-experience,OSU Summer Veterinary Experience,Oregon State U,Veterinary Medicine,,Confirm w/ website,1 week,Rising 11 - 12,$750,44.5646,-123.2620
   https://sites.uci.edu/ncis/,Nursing Camp in Summer (NCIS),UC Irvine,Nursing,,Rolling,1 week,Rising 11 - 12,$2000,33.6405,-117.8443
   https://precollege.adelphi.edu/programs/nursing/,Introduction to Nursing,Adelphi U,Nursing,,,2 weeks,10 - 12,$1800,40.7262,-73.5107
   https://summer.georgetown.edu/programs/SHS26/nursing-academy,Nursing Academy,Georgetown U,Nursing,,Rolling,1 week,Rising 10 - 12,$3025,38.9076,-77.0723
   https://www.thesca.org/serve/youth-programs,Student Conservation Association (SCA),Multiple,Environmental Science,,March (confirm w/ website),Confirm w/ website,15 - 19,Free,38.9072,-77.0369
   https://precollege.brown.edu/bell-alaska/,Brown Environmental Leadership Lab (BELL),"Anchorage, AK",Environmental Science,,February 25Rolling,2 weeks,Rising 10 - 12Ages ​15 - 18,$5984,61.2181,-149.9003
   http://summer.sewanee.edu/high-school-students/fieldstudy/,Sewanee Environmental Institute,Sewanee U of the South,Environmental Science,,Rolling,2 weeks,Rising 11 - 12,$1900,35.2037,-85.9218
   https://www.somas.stonybrook.edu/education/undergrad_course_mar104/,Oceanography @ Stony Brook Southampton,Stony Brook Southampton,Environmental Science,,Rolling,2 weeks,High School ​16+,$3000 tuition + ​$800 housing,40.8844,-72.3897
   https://www.sea.edu/high_school_programs,SEA Semester Summer Programs,"Woods Hole, MA",Environmental Science,,Rolling,2 - 3 weeks,9 - 12,"$5,000~",41.5265,-70.6716
   https://sce.cornell.edu/precollege/program/shoals,Cornell Summer Program Shoals Marine Laboratory,"Appledore Island, Maine",Environmental Science,,Rolling,Confirm w/ website,"Current sophomores, juniors & seniors",Confirm w/ website,42.9779,-70.6103
   https://sce.cornell.edu/precollege/program/architecture,Introduction to Architecture,Cornell U,Architecture,,Open mid-January​Rolling,6 weeks,Juniors / Seniors,"$13,500 (residential + tuition)",42.4534,-76.4735
   https://www.cmu.edu/pre-college/academic-programs/architecture.html#applicationrequirements,CMU Architecture,Carnegie Mellon U,Architecture,,Preferred 3/1​Final 3/15,6 weeks,Rising juniors / seniors,"$6,761 Tuition + Residential",40.4433,-79.9436
   https://ced.berkeley.edu/academics/summer-programs/embarc-design-academy,EMBARC,UC Berkeley,Architecture,,12/15 - 4/17,4 weeks,Rising juniors / seniors,"Tuition $4,358​Residential $8,798",37.8719,-122.2585
   https://arch.usc.edu/high-school-program-exploration-of-architecture,USC Architecture,USC,Architecture,,Confirm on program website,4 weeks,Rising 10 - 12,"$9,126 (tuition + residential)",34.0224,-118.2851
   https://www.summer.ucla.edu/institutes/TeenArchStudio,Teen ArchStudio Summer Institute,UCLA,Architecture,,,3 weeks,Confirm with website,Confirm with website,34.0689,-118.4452
   https://jkcp.com/program/architecture-summer-at-penn/,Architecture: Summer at Penn,UPenn,Architecture,,February 28,4 weeks,9 - 12,$7.800,39.9522,-75.1932
   https://samfoxschool.wustl.edu/summer/adp,Architecture Discovery Program,Wash U St. Louis,Architecture,,3/15 Scholarship4/15 Final,2 weeks,Rising juniors / seniors (recommended),"$3,359",38.6488,-90.3108
   https://wit.edu/summerfab,summerFAB High School Architecture Program,Wentworth Institute of Technology (Boston),Architecture,,4/15,4 weeks,Confirm @ program website,"$4,000 (tuition + residential)",42.3370,-71.0955
   https://www.sothebysinstitute.com/nyc-summer-institute/?utm_source=google&utm_medium=cpc&utm_campaign=precollege&Cid=7011o000000mVoC&creative=334522049999&keyword=secondary%20school%20programs&matchtype=b&network=g&device=c&gclid=EAIaIQobChMIrOrlv9Gl5wIVpB-tBh3fhwreEAMYASAAEgIbtPD_BwE,Sotheby's Summer Institute,NYC,Art,,February 10,2 weeks,10 - 12,$5595 (residential + tuition),40.7128,-74.0060
   https://www.csssa.ca.gov,CSSSA  ,"CalArts (Valenica, CA)",Art,,February 12,4 weeks,9 - 12,$2250 (residential + tuition),34.4147,-118.5698
   https://camp.interlochen.org/program/visual-arts/hs/advanced-drawing,Advanced Drawing or Painting @ Interlochen,"Interlochen, MI",Art,,Priority - January​Rolling,3 weeks,9 - 12,$6100 (tuition + residential),44.6333,-85.7686
   https://sce.cornell.edu/precollege/program/art-experience,Art as Experience @ Cornell,Cornell,Art,,May 1 (rolling),3 weeks,10 - 12,$6750 (residential + tuition),42.4534,-76.4735
   https://mcad.edu/academic-programs/pre-college-summer-session,MCAD Pre-College,Minneapolis College of Art and Design,Art,,Confirm w/ website,2 weeks,10 - 12,$2500,44.9778,-93.2650
   https://www.mica.edu/non-degree-learning-opportunities/programs-for-youth/programs-for-teens/summer-pre-college-program/,MICA Pre-College Art & Design,"Maryland Institute College of Art (Baltimore, MD)",Art,,Nov 1 - April 30Rolling,2 - 5 weeks,High School,2 weeks $2850 3 weeks $4110 ​5 weeks $6400,39.3113,-76.6150
   https://samfoxschool.wustl.edu/summer/portplus,Portfolio Plus @ WashU,Wash U St. Louis,Art,,,3 weeks,Confirm w/ website,$5327 (tuition + residential),38.6488,-90.3108
   https://precollege.risd.edu,RISD Pre-College,"RISD (Providence, RI)",Art,,Rolling,6 weeks,High School,Tuition $6641Residential $2925,41.8268,-71.4098
   https://sfai.edu/public-youth-education/precollege/application,San Francisco Art Institute Pre-College,San Francisco Art Institute,JArt,,anuary 4 Rolling​April 1 Priority​May 1 Final,4 weeks,Rising junior / senior,Confirm w/ website,37.8024,-122.4173
   https://www.scad.edu/academics/pre-college-summer-programs/scad-rising-star,SCAD Rising Star,Savannah ​Atlanta,Art,,May 15 Priority,5 weeks,Rising senior,$6300 (tuition + residential)​,32.0809,-81.0912
   https://www.summer.ucla.edu/institutes/Art,UCLA Art Summer Institute,UCLA,Art,,February 15 Rolling,2 weeks~,14 - 17,$2200~ tuition$1440 residential,34.0689,-118.4452
   https://www.otis.edu/summer-art,Summer of Art,"Otis College of Art & Design, Los Angeles",Art,,March 13 (Priority / Scholarship),4 weeks,15+,$3750 (tuition + residential),34.0558,-118.3949
   https://www.pratt.edu/academics/continuing-education-and-professional/precollege/summer-programs/,Pratt Institute Pre-College,"Pratt (Brooklyn, NY)",Art,,Open December (limited merit scholarship),4 weeks,16 - 18,$6394 (tuition + residential),40.6922,-73.9639
   https://www.bu.edu/cfa/vasi/admissions/,BU Visual Arts Summer Institute (VASI),Boston U,Art,,March 1,4 weeks,Rising 10 - 12,$5500~ (residential + tuition),42.3505,-71.1054
   https://sce.cornell.edu/precollege/program/design-immersion,Cornell Design Immersion,Cornell U,Design,,Opens mid-January ​Rolling,3 weeks,Juniors / Seniors,"$6,750",42.4534,-76.4735
   https://www.summer.ucla.edu/institutes/DesignMediaArts,UCLA DMA Summer Institute,UCLA,Design,,,2 weeks,9 - 12,Tuition $2020​Residential $1224,34.0689,-118.4452
   https://www.cmu.edu/pre-college/academic-programs/design.html,CMU Pre-College Design,Carnegie Mellon U,Design,,Preferred: March 1Final: March 15Rolling,6 weeks,Rising 11 - 12,"$9,259",40.4433,-79.9436
   https://www.ringling.edu/content/precollege-core-classes,Pre-College Design,Ringling College of Art & Design,Design,,Opens November 1 (rolling),4 weeks,10 - 12,$6020,27.3364,-82.5307
   https://design.gatech.edu/precollege,Pre-College Design Program,Georgia Tech U,Design,,April 3,2 weeks,Rising junior / seniors,$2300 (residential + tuition),33.7756,-84.3963
   https://opencampus.newschool.edu/program/summer-programs/youth-teen-programs/summer-intensive-studies-new-york,New School Summer Intensive Studies,NYC New School / Parsons,Design,,Rolling,3 weeks,16+,$3302,40.7353,-73.9970
   https://combeyond.bu.edu/workshop/academy-of-media-production/,Academy of Media Production,Boston U,Film & Video,,Rolling,4 weeks,Rising 10 - 12,"$6,450 (tuition + residential)",42.3505,-71.1054
   https://www.chapman.edu/dodge/summer-programs/summer-film-academy/index.aspx,Summer Film Academy,Chapman U (Los Angeles),Film & Video,,March 1,2 weeks,Rising 11 - 12,"$3,100 (tuition + residential)",33.8753,-117.8531
   https://tisch.nyu.edu/special-programs/high-school-programs/filmmakers-workshop,Tisch Summer High School Filmmakers Workshop,NYU,Film & Video,,January 8,4 weeks,Rising Senior,See program website,40.7295,-73.9965
   https://tisch.nyu.edu/special-programs/high-school-programs/photography-and-imaging,Tisch Summer High School Photography & Imaging Program,NYU,Film & Video,,January 8,4 weeks,Rising 11 - 12,"$12,606",40.7295,-73.9965
   https://www.emerson.edu/majors-programs/pre-college-programs/pre-college-digital-filmmakers,Digital Filmmakers,Emerson U (Boston),Film & Video,,,5 weeks,Rising 10 - 12,"Tuition $4,675Residential $3,080",42.3521,-71.0659
   https://nhsi.northwestern.edu/film-video-division/,Northwestern Cherub National High School Institute,Northwestern U,Film & Video,,Early: January 17Regular: March 13,5 weeks,Rising 11 - 12,"$6,050",42.0565,-87.6753
   http://www.tft.ucla.edu/programs/summer-programs/ucla-film-and-television-summer-institute/,UCLA Film & TV Summer Institute,UCLA,Film & Video,,See program website,2 weeks,Rising 11 - 12,See program website,34.0689,-118.4452Link,Program,Location,Category,Selectivity,Application Date,Duration,Eligibility,Cost
"""
    
    let lines = csvContent.components(separatedBy: .newlines)
        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    
    guard lines.count > 1 else { return [] }
    
    var programs: [Program] = []

    for i in 1..<lines.count {
        let line = lines[i]
        let components = parseCSVLine(line)
        
        if components.count >= 11 {
            guard let latitude = Double(components[9]),
                let longitude = Double(components[10]) else {
                continue
            }
            let program = Program(
                link: components[0],
                name: components[1],
                location: components[2],
                category: components[3],
                selectivity: components[4],
                applicationDate: components[5],
                duration: components[6],
                restrictions: components[7],
                cost: components[8],
                latitude: latitude,
                longitude: longitude,
                likeSkip: false
            )
            programs.append(program)
        }
       
    }
   
    return programs
}

func parseCSVLine(_ line: String) -> [String] {
    var components: [String] = []
    var currentComponent = ""
    var insideQuotes = false
    var i = line.startIndex
    
    while i < line.endIndex {
        let char = line[i]
        
        if char == "\"" {
            insideQuotes.toggle()
        } else if char == "," && !insideQuotes {
            components.append(currentComponent.trimmingCharacters(in: .whitespaces))
            currentComponent = ""
        } else {
            currentComponent.append(char)
        }
        
        i = line.index(after: i)
    }

    components.append(currentComponent.trimmingCharacters(in: .whitespaces))
    
    return components
}
