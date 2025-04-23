#!/bin/bash

# Authors: Kainat Zahra (23F-0713), Mehreen Fatima (23F-0611)
# BSCS Student Management System

DATA_FILE="savedstudent_data.txt"
if [ ! -f "$DATA_FILE" ]; then
touch "$DATA_FILE"
fi

MAX_STUDENTS=20

# Arrays in use
students=()
grade1=()
grade2=()
grade3=()
marks1=()
marks2=()
marks3=()
cgpa=()
roll_numbers=()

grade_calculation() {
local marks=$1
if ((marks >= 90)); then echo "A"
elif ((marks >= 80)); then echo "B"
elif ((marks >= 70)); then echo "C"
elif ((marks >= 60)); then echo "D"
else echo "F"
fi
}

grade_to_gpa() {
case $1 in
A) echo "4.0";;
B) echo "3.0";;
C) echo "2.0";;
D) echo "1.0";;
F) echo "0.0";;
*) echo "0.0";;
esac
}

calculate_gpa() {
g1=$(grade_to_gpa "$1")
g2=$(grade_to_gpa "$2")
g3=$(grade_to_gpa "$3")
echo "scale=2; ($g1 + $g2 + $g3) / 3" | bc
}

save_student_data() {
grep -v "^$1 " "$DATA_FILE" > temp.txt && mv temp.txt "$DATA_FILE"
echo "$1 $2 $3 $4 $5 $6 $7 $8 $9" >> "$DATA_FILE"
}

load_student_data() {
grep "^$1 " "$DATA_FILE" 2>/dev/null
}

assign_marks() {
echo "Enter roll number of student to assign marks:"
read roll
found=0
for ((i=0; i<${#roll_numbers[@]}; i++)); do
if [[ "${roll_numbers[i]}" == "$roll" ]]; then
echo "Enter new marks for Operating Systems:"
read marks1[i]
echo "Enter new marks for Database:"
read marks2[i]
echo "Enter new marks for Probability:"
read marks3[i]

grade1[i]=$(grade_calculation "${marks1[i]}")
grade2[i]=$(grade_calculation "${marks2[i]}")
grade3[i]=$(grade_calculation "${marks3[i]}")
cgpa[i]=$(calculate_gpa "${grade1[i]}" "${grade2[i]}" "${grade3[i]}")

save_student_data "${roll_numbers[i]}" "${students[i]}" "${marks1[i]}" "${marks2[i]}" "${marks3[i]}" "${grade1[i]}" "${grade2[i]}" "${grade3[i]}" "${cgpa[i]}"
echo "Marks assigned successfully."
found=1
break
fi
done
if [[ $found -eq 0 ]]; then
echo "Student not found."
fi
}

add_student() {
if ((${#students[@]} >= MAX_STUDENTS)); then
echo "Limit reached. No more students can be added."
return
fi

echo "Enter roll number:"
read roll
if grep -q "^$roll " "$DATA_FILE"; then
echo "Roll number already exists."
return
fi

echo "Enter name:"
read name
echo "Enter marks for Operating Systems:"
read m1
echo "Enter marks for Database:"
read m2
echo "Enter marks for Probability:"
read m3

g1=$(grade_calculation "$m1")
g2=$(grade_calculation "$m2")
g3=$(grade_calculation "$m3")
gpa=$(calculate_gpa "$g1" "$g2" "$g3")

students+=("$name")
roll_numbers+=("$roll")
marks1+=("$m1")
marks2+=("$m2")
marks3+=("$m3")
grade1+=("$g1")
grade2+=("$g2")
grade3+=("$g3")
cgpa+=("$gpa")

save_student_data "$roll" "$name" "$m1" "$m2" "$m3" "$g1" "$g2" "$g3" "$gpa"
echo "Student added successfully."
}

pass_list() {
echo "Students who passed (CGPA >= 2.0):"
for ((i=0; i<${#students[@]}; i++)); do
if [[ -n "${cgpa[i]}" ]]; then
if [ "$(echo "${cgpa[i]} >= 2" | bc -l)" -eq 1 ]; then
echo "${students[i]} - ${roll_numbers[i]}"
fi
fi
done
}

fail_list() {
echo "Students who failed (CGPA < 2.0):"
for ((i=0; i<${#students[@]}; i++)); do
if [[ -n "${cgpa[i]}" ]]; then
if [ "$(echo "${cgpa[i]} < 2" | bc -l)" -eq 1 ]; then
echo "${students[i]} - ${roll_numbers[i]}"
fi
fi
done
}

ascending_list() {
temp_cgpa=("${cgpa[@]}")
temp_stu=("${students[@]}")
temp_roll=("${roll_numbers[@]}")
for ((i=0; i<${#temp_cgpa[@]}; i++)); do
for ((j=i+1; j<${#temp_cgpa[@]}; j++)); do
if (( $(echo "${temp_cgpa[i]} > ${temp_cgpa[j]}" | bc -l) )); then
temp=${temp_cgpa[i]}; temp_cgpa[i]=${temp_cgpa[j]}; temp_cgpa[j]=$temp
temp=${temp_stu[i]}; temp_stu[i]=${temp_stu[j]}; temp_stu[j]=$temp
temp=${temp_roll[i]}; temp_roll[i]=${temp_roll[j]}; temp_roll[j]=$temp
fi
done
done
echo "Students sorted by CGPA (Ascending):"
for ((i=0; i<${#temp_stu[@]}; i++)); do
echo "${temp_stu[i]} - ${temp_roll[i]} - ${temp_cgpa[i]}"
done
}

descending_list() {
temp_cgpa=("${cgpa[@]}")
temp_stu=("${students[@]}")
temp_roll=("${roll_numbers[@]}")
for ((i=0; i<${#temp_cgpa[@]}; i++)); do
for ((j=i+1; j<${#temp_cgpa[@]}; j++)); do
if (( $(echo "${temp_cgpa[i]} < ${temp_cgpa[j]}" | bc -l) )); then
temp=${temp_cgpa[i]}; temp_cgpa[i]=${temp_cgpa[j]}; temp_cgpa[j]=$temp
temp=${temp_stu[i]}; temp_stu[i]=${temp_stu[j]}; temp_stu[j]=$temp
temp=${temp_roll[i]}; temp_roll[i]=${temp_roll[j]}; temp_roll[j]=$temp
fi
done
done
echo "Students sorted by CGPA (Descending):"
for ((i=0; i<${#temp_stu[@]}; i++)); do
echo "${temp_stu[i]} - ${temp_roll[i]} - ${temp_cgpa[i]}"
done
}

report() {
echo "--------- REPORT ---------"
pass_list
echo
fail_list
echo
ascending_list
echo
descending_list
echo "--------------------------"
}

delete_student() {
echo "Enter roll number of student to delete:"
read roll
exists=0
for ((i=0; i<${#students[@]}; i++)); do
if [[ "${roll_numbers[i]}" == "$roll" ]]; then
unset students[i] roll_numbers[i] marks1[i] marks2[i] marks3[i] grade1[i] grade2[i] grade3[i] cgpa[i]
grep -v "^$roll " "$DATA_FILE" > temp.txt && mv temp.txt "$DATA_FILE"
students=("${students[@]}")
roll_numbers=("${roll_numbers[@]}")
marks1=("${marks1[@]}")
marks2=("${marks2[@]}")
marks3=("${marks3[@]}")
grade1=("${grade1[@]}")
grade2=("${grade2[@]}")
grade3=("${grade3[@]}")
cgpa=("${cgpa[@]}")
echo "Student record deleted."
exists=1
break
fi
done
if [[ $exists -eq 0 ]]; then
echo "Student not found."
fi
}

update_student() {
echo "Enter roll number to update marks:"
read roll
exists=0
for ((i=0; i<${#students[@]}; i++)); do
if [[ "${roll_numbers[i]}" == "$roll" ]]; then
choice=0
while [[ $choice -ne 4 ]]; do
echo "1. Update Operating Systems"
echo "2. Update Database"
echo "3. Update Probability"
echo "4. Exit"
read choice
case $choice in
1) echo "Enter new marks:"; read marks1[i];;
2) echo "Enter new marks:"; read marks2[i];;
3) echo "Enter new marks:"; read marks3[i];;
4) break;;
*) echo "Invalid choice";;
esac
grade1[i]=$(grade_calculation "${marks1[i]}")
grade2[i]=$(grade_calculation "${marks2[i]}")
grade3[i]=$(grade_calculation "${marks3[i]}")
cgpa[i]=$(calculate_gpa "${grade1[i]}" "${grade2[i]}" "${grade3[i]}")
save_student_data "${roll_numbers[i]}" "${students[i]}" "${marks1[i]}" "${marks2[i]}" "${marks3[i]}" "${grade1[i]}" "${grade2[i]}" "${grade3[i]}" "${cgpa[i]}"
done
exists=1
break
fi
done
if [[ $exists -eq 0 ]]; then
echo "Student not found."
fi
}

view_grade() {
echo -n "Enter your roll number: "
read roll
data=$(load_student_data "$roll")
if [[ -z "$data" ]]; then echo "Student not found"; return; fi
read -r roll name m1 m2 m3 g1 g2 g3 cgpa <<< "$data"
echo "Grades for $name:"
echo "OS: $g1 | DB: $g2 | Probability: $g3"
}

view_cgpa() {
echo "Enter your roll number:"
read roll
data=$(load_student_data "$roll")
if [[ -z "$data" ]]; then echo "Student not found"; return; fi
read -r roll name m1 m2 m3 g1 g2 g3 cgpa <<< "$data"
echo "CGPA of $name: $cgpa"
}

student_menu() {
while true; do
echo "----- STUDENT MENU -----"
echo "1. View Grades"
echo "2. View CGPA"
echo "3. Back"
read choice
case $choice in
1) view_grade;;
2) view_cgpa;;
3) return;;
*) echo "Invalid";;
esac
done
}

teacher_menu() {
while true; do
echo "----- TEACHER MENU -----"
echo "1. Add Student"
echo "2. Delete Student"
echo "3. Assign Marks"
echo "4. List Passed Students"
echo "5. List Failed Students"
echo "6. List Ascending CGPA"
echo "7. List Descending CGPA"
echo "8. Update Student"
echo "9. Generate Report"
echo "10. Back"
read choice
case $choice in
1) add_student;;
2) delete_student;;
3) assign_marks;;
4) pass_list;;
5) fail_list;;
6) ascending_list;;
7) descending_list;;
8) update_student;;
9) report;;
10) return;;
*) echo "Invalid";;
esac
done
}

main_menu() {
while true; do
echo "------ MAIN MENU ------"
echo "1. Login as Teacher"
echo "2. Login as Student"
echo "3. Exit"
read opt
case $opt in
1) teacher_menu;;
2) student_menu;;
3) echo "Goodbye!"; exit;;
*) echo "Invalid choice";;
esac
done
}

main_menu
