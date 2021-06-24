<ul class="sidebar-menu" data-widget="tree">
				 <li class="<?php if($page==DASHBOARD) echo " active"; ?> ">
						<a href="<?php echo site_url(DASHBOARD); ?>">
						<i class="fa fa-home"></i> <span>Dashboard</span>
						</a>
				 </li>
				 <li class="<?php if($page==ROLEACCESS) echo " active"; ?> ">
						<a href="<?php echo site_url(ROLEACCESS); ?>">
						<i class="fa fa-home"></i> <span>Admin Users</span>
						</a>
				 </li>
				 <li class="<?php if($split[0]==USERS) echo " active"; ?>">
						<a href="<?php echo site_url(USERS); ?>"> 
						<i class="fa fa-users"></i>
						<span>Users Management</span>
						</a>
				 </li>
				<li class="treeview <?php if($page==SETTINGS || $page==DAYWISETIMINGS) echo " active"; ?>">
					<a href="javascript:void(0)">
						<i class="fa fa-th"></i> <span>Manage Appearances</span>
						<span class="pull-right-container">
							<i class="fa fa-angle-left pull-right"></i>
						</span>
					</a>
					<ul class="treeview-menu <?php if($page==SETTINGS || $page==DAYWISETIMINGS) echo " active"; ?>">
						<li class="<?php if($page==SETTINGS) echo " active"; ?>">
							<a href="<?php echo site_url(SETTINGS); ?>">
								<i class="fa fa-gears"></i><span>Settings</span>
							</a>
						</li>
						<!-- <li class="<?php if($page==DAYWISETIMINGS) echo " active"; ?>">
							<a href="<?php echo site_url(DAYWISETIMINGS); ?>">
								<i class="fa fa-clock-o"></i><span>Daywise Timings</span>
							</a>
						</li> -->
					</ul>
				</li>
				 <li class="<?php if($split[0]==REFERRAL) echo " active"; ?>">
						<a href="<?php echo site_url(REFERRAL); ?>">
							 <i class="fa fa-user-plus"></i>
							 <!-- <i class="fa fa-compress-alt"></i> -->
							 <span>Referral List</span>
						</a>
				 </li>
				 <li class="<?php if($split[0]==TOURNAMENTS) echo " active"; ?>">
						<a href="<?php echo site_url(TOURNAMENTS); ?>">
							 <i class="fa fa-user-plus"></i>
							 <!-- <i class="fa fa-compress-alt"></i> -->
							 <span>Tournaments</span>
						</a>
				 </li>
				 <li class="<?php if($split[0]==PAYMENTTRANSACTION) echo " active"; ?>">
						<a href="<?php echo site_url(PAYMENTTRANSACTION); ?>">
							 <i class="fa fa-credit-card"></i>
							 <!-- <i class="fa fa-compress-alt"></i> -->
							 <span> Payment Transactions</span>
						</a>
				 </li>
				 <!-- <li class="<?php if ($page==GAMERECORD) echo "active"; ?>">
						<a href="<?php echo site_url(GAMERECORD); ?>"> 
						<i class="fa fa-trophy"></i>
						<span> Game Record</span>
						</a>
				 </li> -->
				 <li class="treeview <?php if($split[0]==WITHDRAWAL || $split[0]==WITHDRAWALCOMPREQ || $split[0]==WITHDRAWALREJECTREQ ) echo " active"; ?>">
						<a href="javascript:void(0)">
						<i class="fa fa-calculator"></i> <span>Payout Management</span>
						<span class="pull-right-container">
						<i class="fa fa-angle-left pull-right"></i>
						</span>
						</a>
						<ul class="treeview-menu <?php if($split[0]==WITHDRAWAL || $split[0]==WITHDRAWALCOMPREQ || $split[0]==WITHDRAWALREJECTREQ ) echo " active"; ?>">
							 <li class="<?php if ($page==WITHDRAWAL) echo "active"; ?>">
									<a href="<?php echo site_url(WITHDRAWAL); ?>"> 
									<i class="fa fa-hourglass-start"></i><span>Withdrawal Request</span>
									</a>
							 </li>
							 <li class="<?php if ($page==WITHDRAWALCOMPREQ) echo "active"; ?>">
									<a href="<?php echo site_url(WITHDRAWALCOMPREQ); ?>"> 
									<i class="fa fa-check-square-o"></i><span>Completed Request</span>
									</a>
							 </li>
							 <li class="<?php if ($page==WITHDRAWALREJECTREQ) echo "active"; ?>">
									<a href="<?php echo site_url(WITHDRAWALREJECTREQ); ?>"> 
									<i class="fa fa-close"></i> <span>Rejected Request</span>
									</a>
							 </li>
							 <!-- <li class="<?php if ($page==WITHDRAWALBANKEXPORT) echo "active"; ?>">
									<a href="<?php echo site_url(WITHDRAWALBANKEXPORT); ?>"> 
									<i class="fa fa-file"></i> <span>Bank Export Request</span>
									</a>
							 </li> -->
						</ul>
				 </li>
				 <li class="<?php if ($page==MAINTAINANCE) echo "active"; ?>">
						<a href="<?php echo site_url(MAINTAINANCE); ?>"> 
						<i class="fa fa-wrench"></i> <span>Maintenance</span>
						</a>
				 </li>
				 <li class="<?php if($split[0]==GAMEPLAY) echo " active"; ?>">
						<a href="<?php echo site_url(GAMEPLAY); ?>">
						<i class="fa fa-gamepad"></i>
						<span>Rooms</span>
						</a>
				 </li>
					<li class="<?php if($split[0]==BONUS) echo " active"; ?>">
						<a href="<?php echo site_url(BONUS); ?>">
							<i class="fa fa-money"></i>
							<span>Bonus</span>
						</a>
					</li> 

				 <li class="<?php if($split[0]==DEPOSIT) echo " active"; ?>">
					<a href="<?php echo site_url(DEPOSIT); ?>">
						<i class="fa fa-money"></i>
						<span>Deposit</span>
					</a>
				 </li>
				 
				 <li class="<?php if($split[0]==KYC) echo " active"; ?>">
					<a href="<?php echo site_url(KYC); ?>">
						<i class="fa fa-money"></i>
						<span>KYC</span>
					</a>
				 </li>

				 <li class="<?php if($split[0]==BOTPLAYER) echo " active"; ?>">
					<a href="<?php echo site_url(BOTPLAYER); ?>">
						<i class="fa fa-user-circle-o"></i>
						<span>Manage Bot Player</span>
					</a>
				 </li>

				 
				 
				<!--   <li class="<?php if($split[0]==CONTACTUS) echo " active"; ?>">
					<a href="<?php echo site_url(CONTACTUS); ?>">
						<i class="fa fa-phone"></i>
						<span>Contact Us</span>
					</a>
				 </li>-->
				 
				 <!-- <li class="<?php if($flag=='bot-win') echo " active"; ?>">
					<a href="<?php echo site_url(BOTREPORT.'/bot-win'); ?>">
						<i class="fa fa-file"></i>
						<span>Bot Win Reports </span>
					</a>
				 </li>

				 <li class="<?php if($flag=='bot-loss') echo " active"; ?>">
					<a href="<?php echo site_url(BOTREPORT.'/bot-loss'); ?>">
						<i class="fa fa-file"></i>
						<span>Bot Loss Reports </span>
					</a>
				 </li> -->

				 <li class="<?php if($split[0]==USERREPORT) echo " active"; ?>">
					<a href="<?php echo site_url(USERREPORT); ?>">
						<i class="fa fa-file"></i>
						<span>Report</span>
					</a>
				 </li>

				 <li class="<?php if($split[0]==MATCHHISTORY) echo " active"; ?>">
					<a href="<?php echo site_url(MATCHHISTORY); ?>">
						<i class="fa fa-gamepad"></i>
						<span>Game Record</span>
					</a>
				 </li>

				 <li class="<?php if($split[0]==COUPONCODE) echo " active"; ?>">
					<a href="<?php echo site_url(COUPONCODE); ?>">
						<i class="fa fa-user-circle-o"></i>
						<span>Coupon Code</span>
					</a>
				 </li> 

				 <li class="<?php if($split[0]==SPINROLL) echo " active"; ?>">
					<a href="<?php echo site_url(SPINROLL); ?>">
						<i class="fa fa-user-circle-o"></i>
						<span>Spin Rolls</span>
					</a>
				 </li> 

				<!--  <li class="<?php if($split[0]==SUPPORTS) echo " active"; ?>">
					<a href="<?php echo site_url(SUPPORTS); ?>">
						<i class="fa fa-comments-o"></i>
						<span>Supports</span>
					</a>
				 </li> -->

			</ul>