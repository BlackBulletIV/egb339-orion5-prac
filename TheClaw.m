classdef TheClaw < Orion5
    %TheClaw a Class to be used by EGB339 students
    %   TheClaw inherits all of Orion5 class refer documentation for
    %   details
    
    properties
        % define global properties of TheClaw here
        POS_X = 0.1;
        POS_Y = 0.29;
        
        %offsets in the base of the robot
        OFFSET_R = 0.030309;
        OFFSET_Z = 0.053;
        
        %link lengths for the orion5
        LINK_1 = 0.170384;
        LINK_2 = 0.136307;
        LINK_3 = 0.126;
        
        %JOINT_ANGLES used to keep track of the robots angles converted
        %from joint space
        JOINT_ANGLES = nan;
        
        % DES_JOINT_ANGLES modified to suite robot i.e. scaled
        % for gearboxes and the like and should not be used for current
        % angles
        DES_JOINT_ANGLES = nan;
        
        
        JOINT_OFFSET = [57.5, 9, 4, 0, 0];
        
        GEAR_RATIOS = [1, 2.857, 1, 1, 1];
        
        MOVE_TIME = 3;
        CLAW_MOVE_TIME = 7;
    end
    
    methods
        function self = TheClaw()
            self@Orion5();
            self.setup();
        end
        
        function setup(self)
            for i = self.BASE:self.CLAW
                self.setJointTorqueEnable(i, 1);
                self.setJointControlMode(i, self.POS_TIME);
                self.setJointTimeToPosition(i, self.MOVE_TIME);
            end
            
            self.setJointTimeToPosition(self.CLAW, self.CLAW_MOVE_TIME);
        end
        
        function open(self)
            self.setJointPosition(self.CLAW, 300);
            pause(self.CLAW_MOVE_TIME);
        end
        
        function close(self)
            self.setJointPosition(self.CLAW, 80);
            pause(self.CLAW_MOVE_TIME);
        end
        
        function [t1, t2, t3, t4] = inverse_kinematics(self, x, y, z)
            a1 = self.LINK_1;
            a2 = self.LINK_2;
            a3 = self.LINK_3;
            x = x - self.POS_X;
            y = y - self.POS_Y;
            
            l = sqrt(x ^ 2 + y ^ 2) - self.OFFSET_R; % serves as x in the 2D solution
            t1 = atan2(y, -x);
            z = z + a3 - self.OFFSET_Z; % subtract wrist link
            c = sqrt(l ^ 2 + z ^ 2); % base to wrist
            t3 = acos((a1 ^ 2 + a2 ^ 2 - c ^ 2) / (2 * a1 * a2));
            
            theta = acos((c ^ 2 + a1 ^ 2 - a2 ^ 2) / (2 * c * a1)); % ang between base and wrist
            t2 = atan2(z, l) + theta;
            
            x2 = a1 * cos(t2);
            z2 = a1 * sin(t2);
            d = sqrt((l - x2) ^ 2 + (z - a3 - z2) ^ 2); % wrist to end effector
            t4 = acos((a2 ^ 2 + a3 ^ 2 - d ^ 2) / (2 * a2 * a3));
            
            t1 = t1 * (180/pi);
            t2 = t2 * (180/pi);
            t3 = t3 * (180/pi);
            t4 = t4 * (180/pi);
        end
        
        function move_to(self, x, y, z)
            [t1, t2, t3, t4] = self.inverse_kinematics(x, y, z);
            t1 = t1 + self.JOINT_OFFSET(1);
            t2 = t2 + self.JOINT_OFFSET(2);
            t3 = t3 + self.JOINT_OFFSET(3);
            t4 = t4 + self.JOINT_OFFSET(4);
            
            if t2 < 10 || t2 > 122
                error('Shoulder angle out of range');
            end
            
            if t3 < 20 || t3 > 340
                error('Elbow angle out of range');
            end
            
            if t4 < 45 || t4 > 315
                error('Wrist angle out of range');
            end
                       
            self.setJointPosition(self.BASE, t1 * self.GEAR_RATIOS(1));
            self.setJointPosition(self.SHOULDER, t2 * self.GEAR_RATIOS(2));
            self.setJointPosition(self.ELBOW, t3 * self.GEAR_RATIOS(3));
            self.setJointPosition(self.WRIST, t4 * self.GEAR_RATIOS(4));
            pause(self.MOVE_TIME);
        end
    end
end
 