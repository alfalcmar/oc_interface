#include "FORCESNLPsolver.h"
#include <ros/ros.h>
#include <geometry_msgs/PoseStamped.h>
#include <nav_msgs/Path.h>
#include <uav_abstraction_layer/TakeOff.h>
#include <geometry_msgs/TwistStamped.h>
#include <nav_msgs/Odometry.h>
//#include "uav_path_manager/GeneratePath.h"
//#include "uav_path_manager/GetGeneratedPath.h"
#include <thread>
#include <uav_abstraction_layer/GoToWaypoint.h>
#include <optimal_control_interface.h>
#include <uav_abstraction_layer/State.h>



ros::Publisher set_pose_pub;
ros::Publisher set_velocity_pub;
ros::Subscriber uav_state_sub;

// solver output
std::vector<double> x;   
std::vector<double> y;
std::vector<double> z;
std::vector<double> vx;
std::vector<double> vy;
std::vector<double> vz;

// trajectory to send to UAL
std::vector<double> x_ual;
std::vector<double> y_ual;
std::vector<double> z_ual;
std::vector<double> vx_ual;
std::vector<double> vy_ual;
std::vector<double> vz_ual;


bool solver_success; 
int ual_state;

void uavTrajectoryCallback(const optimal_control_interface::SolvedTrajectory::ConstPtr &msg, int id){
    uavs_trajectory.clear();
    uavs_trajectory[id] = msg->positions;
}



/** callback for ual pose*/

void uavPoseCallback(const geometry_msgs::PoseStamped::ConstPtr &msg, int id){
    if(!trajectory_solved_received[id]){
        for(int i=0; i<time_horizon;i++){
            geometry_msgs::Point pose_aux;
            pose_aux.x = msg->pose.position.x;
            pose_aux.y = msg->pose.position.y;
            pose_aux.z = msg->pose.position.z;
            uavs_trajectory[id].push_back(pose_aux);
        }
    }
    uavs_pose[id].pose = msg->pose;
}

/** callback for ual state
 */

void ualStateCallback(const uav_abstraction_layer::State::ConstPtr &msg){
    ual_state = msg->state;
}

/** Callback for the target pose
 */

void targetPoseCallback(const nav_msgs::Odometry::ConstPtr &msg)
{
    target_pose.pose = msg->pose.pose;
}
void targetPrediction(){

}


/** main thread
 */

int main(int _argc, char **_argv)
{
    ros::init(_argc, _argv, "optimal_control_interface_node");
    ros::NodeHandle nh = ros::NodeHandle();
    ros::NodeHandle pnh = ros::NodeHandle("~");
    //utility vars
    int n_steps;
    float solver_rate;

    // parameters
    pnh.param<float>("solver_rate", solver_rate, 10.0);
    std::string target_topic;
    pnh.param<std::string>("target_topic",target_topic, "/drc_vehicle_xp900/odometry");
    std::vector<double> desired_wp; 
    std::vector<double> desired_vel;
    std::vector<double> obst;
    std::vector<double> target_vel = {0, 0};
    std::vector<double> target_pose_init = {0, 0};

    if (ros::param::has("~drones")) {
        ros::param::get("~drones",drones);
    }
    else {
        ROS_WARN("fail to get the drones ids");
    }
    if (ros::param::has("~drone_id")) {
        ros::param::get("~drone_id",drone_id);
    }
    else {
        ROS_WARN("fail to get the drones id");
    }
    if (ros::param::has("~target_final_pose")) {
        ros::param::get("~target_final_pose",target_final_pose);
    }
    else {
        ROS_WARN("fail to get final target pose");
    }
    if (ros::param::has("~target_pose_init")) {
        ros::param::get("~target_pose_init",target_pose_init);
    }
    else {
        ROS_WARN("fail to get initial target pose");
    }
    if (ros::param::has("~target_vel")) {
        ros::param::get("~target_vel",target_vel);
    }
    else {
        ROS_WARN("fail to get target velocity");
    }
    if (ros::param::has("~desired_wp")) {
        ros::param::get("~desired_wp",desired_wp);
    }
    else {
        ROS_WARN("fail to get desidred wp");
    }

    if (ros::param::has("~desired_vel")) {
        ros::param::get("~desired_vel",desired_vel);
    }
    else {
        ROS_WARN("fail to get desired_vel");
    }
    if (ros::param::has("~no_fly_zone")) {
        ros::param::get("~no_fly_zone",obst);
    }
    else {
        ROS_WARN("fail to get no_fly_zone");
    }

    // subscribers and publishers
    ros::Subscriber target_pose_sub = nh.subscribe<nav_msgs::Odometry>(target_topic, 1, targetPoseCallback);
    set_pose_pub = nh.advertise<geometry_msgs::PoseStamped>("ual/set_pose",1);
    set_velocity_pub = nh.advertise<geometry_msgs::TwistStamped>("ual/set_velocity",1);
    desired_pose_publisher = pnh.advertise<geometry_msgs::PointStamped>("/desired_point",1);
    uav_state_sub = nh.subscribe<uav_abstraction_layer::State>("ual/state",1,ualStateCallback);


    for(int i=0; i<drones.size(); i++){
        drone_pose_sub[drones[i]] = nh.subscribe<geometry_msgs::PoseStamped>("/drone_"+std::to_string(drones[i])+"/ual/pose", 10, std::bind(&uavPoseCallback, std::placeholders::_1, drones[i]));               // Change for each drone ID
        drone_trajectory_sub[drones[i]] = nh.subscribe<optimal_control_interface::SolvedTrajectory>("/solver", 1, std::bind(&uavTrajectoryCallback, std::placeholders::_1, drones[i]));
        //initialize
        trajectory_solved_received[drones[i]] = false;   
    }

    // init solver
    init(nh);
    ros::Rate rate(0.0001); //hz
    sleep(5);
    /* main loop to call the solver. */
    while(ros::ok){
        // solver function
          x.clear();
          y.clear();
          z.clear();
        ROS_INFO("calling solver");
        calculateDesiredPoint(shooting_type, target_pose, desired_wp, desired_vel);
        ros::spinOnce();
        solver_success = solverFunction(x,y,z,vx,vy,vz, desired_wp, desired_vel, obst,target_vel);
        sleep(2);
        if(solver_success){
            publishTrajectory(x,y,z,vx,vy,vz);

        // log solver output to csv file
        logToCsv(x,y,z,vx,vy,vz);
        // publish path to rviz visualizer

        // double point_1[2]= {-13.1,-35.55};
        // double point_2[2]= {-2.2,-20.8};
        // double point_3[2]= {10.77,-39.7};
        // double point_4[2]= {-2.5,-51.3};

        // publishNoFlyZone(point_1,point_2,point_3,point_4);

        publishDesiredPoint(desired_wp[0], desired_wp[1], desired_wp[2]);
        publishPath(x,y,z,desired_wp);

        }
        
        if(drone_id==1){
            std::vector<double> target_x;
            std::vector<double> target_y;
            std::vector<double> target_z;


            for(int i=0; i<target_trajectory.size();i++){
                target_x.push_back(target_trajectory[i].x);
                target_y.push_back(target_trajectory[i].y);
                target_z.push_back(target_trajectory[i].z);
            }
            nav_msgs::Path msg;
            std::vector<geometry_msgs::PoseStamped> poses(target_x.size());
            msg.header.frame_id = "map";
            for (int i = 0; i < target_x.size(); i++) {
                poses.at(i).pose.position.x = target_x[i];
                poses.at(i).pose.position.y = target_y[i];
                poses.at(i).pose.position.z = target_z[i];
                poses.at(i).pose.orientation.x = 0;
                poses.at(i).pose.orientation.y = 0;
                poses.at(i).pose.orientation.z = 0;
                poses.at(i).pose.orientation.w = 1;
            }
            msg.poses = poses;
            target_path_rviz_pub.publish(msg);
        
        }
        ros::spinOnce();
        rate.sleep();
    }
    
    //threadObjSolver.join();
    return 0;
}
