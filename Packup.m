clear all; clc;
claw = TheClaw();
claw.setJointPosition(claw.CLAW, 30);
            pause(7)
for id = claw.BASE:claw.WRIST
    claw.setJointTorqueEnable(id, 1);
    claw.setJointControlMode(id, claw.POS_TIME);
    claw.setJointTimeToPosition(id, 2);
end

joint_angles =  [30 260 60 140 20];
claw.setAllJointsPosition(joint_angles);

pause(3.0);
claw.setJointPosition(claw.ELBOW, 40);
claw.setJointPosition(claw.SHOULDER, 350);

 
claw.stop();