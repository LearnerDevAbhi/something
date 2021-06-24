<!-- Load common header -->
<?php $this->load->view('common/header'); ?>

<!-- Load common left panel -->
<?php $this->load->view('common/left_panel.php'); ?>

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1><?= $heading; ?>
      </h1>
      <ol class="breadcrumb">
        <li><a href="<?= site_url(DASHBOARD); ?>"><i class="fa fa-dashboard"></i> Dashboard</a></li>
        <li><a href="<?= site_url(TOURNAMENTS); ?>"><?= $breadhead; ?></a></li>
        <li><?= $bread; ?></li>
      </ol>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="row">
        <div class="col-xs-12">
          <div class="box bShow">
            <div class="box-header with-border">
              <div class="col-md-8 box-title paddLeft"><?= $heading; ?></div>
             <div class="col-md-4 paddRight"> <a href="<?= site_url(TOURNAMENTS); ?>"><button type="button" class="btn btn-danger btn-sm pull-right">BACK</button></a></div>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
              <table class="table table-striped table-bordered">
                <tbody>
                    <tr>
                        <td class="text_view"><b>Tournament Title</b></td>
                        <td>:</td>
                        <td><?php if(!empty($tournamentTitle)){ echo $tournamentTitle; }else{ echo "NA";} ?></td>
                        <td class="text_view"><b>Start Date</b></td>
                        <td>:</td>
                        <td><?php if(!empty($startDate) && $startDate!="0000-00-00"){ echo date("d M Y",strtotime($startDate)); }else{ echo "NA";} ?></td>
                    </tr>

                    <tr>
                        <td class="text_view"><b>Start Time</b></td>
                        <td>:</td>
                        <td><?php if(!empty($startTime) && $startTime!='00:00:00'){ echo date("h:i A",strtotime($startTime)); }else{ echo "NA";} ?></td>
                        <td class="text_view"><b>Description</b></td>
                        <td>:</td>
                        <td><?php if(!empty($tournamentDescription)){ echo $tournamentDescription; }else{ echo "NA";} ?></td>
                    </tr>

                    <tr>
                        <td class="text_view"><b>Winning Price</b></td>
                        <td>:</td>
                        <td><?php if(!empty($winningPrice)){ echo $winningPrice; }else{ echo "NA";} ?></td>
                         <td class="text_view"><b>Status</b></td>
                        <td>:</td>
                        <td>
                          <?php
                            if(!empty($status) && $status == 'Active')
                              $class = 'label label-success';
                            else if($status == 'Inactive')
                              $class = 'label label-danger';
                            else if($status == 'Start')
                              $class = 'label label-info';
                            else if($status == 'Complete')
                              $class = 'label label-primary';
                            else
                              $class = 'label label-primary';
                          ?>
                          <span class="<?= $class; ?>"><?php if(!empty($status)){ echo ucfirst($status); }else{ echo "N/A";} ?></span>
                        </td>
                    </tr>


                     <tr>
                        <td class="text_view"><b>Player Limit In Room</b></td>
                        <td>:</td>
                        <td><?php if(!empty($playerLimitInRoom)){ echo $playerLimitInRoom; }else{ echo "NA";} ?></td>
                        <td class="text_view"><b> No of Round In Tournament</b></td>
                        <td>:</td>
                        <td><?php if(!empty($noOfRoundInTournament)){ echo $noOfRoundInTournament; }else{ echo "NA";} ?></td>
                    </tr>


                    <tr>
                        <td class="text_view"><b>Player Limit In Tournament</b></td>
                        <td>:</td>
                        <td><?php if(!empty($playerLimitInTournament)){ echo $playerLimitInTournament; }else{ echo "NA";} ?></td>
                        <td class="text_view"><b>Commission</b></td>
                        <td>:</td>
                        <td><?php if(!empty($commision)){ echo $commision; }else{ echo "NA";} ?></td>
                    </tr>

                    <tr>
                        <td class="text_view"><b>Start Round Time</b></td>
                        <td>:</td>
                        <td><?php if(!empty($startRoundTime)){ echo $startRoundTime; }else{ echo "NA";} ?></td>
                        <td class="text_view"><b>Token Move Time</b></td>
                        <td>:</td>
                        <td><?php if(!empty($tokenMoveTime)){ echo $tokenMoveTime; }else{ echo "NA";} ?></td>
                    </tr>

                    <tr>
                        <td class="text_view"><b>Current Round</b></td>
                        <td>:</td>
                        <td><?php if(!empty($currentRound)){ echo $currentRound; }else{ echo "NA";} ?></td>
                        <td class="text_view"><b>Register Player Count</b></td>
                        <td>:</td>
                        <td><?php if(!empty($registerPlayerCount)){ echo $registerPlayerCount; }else{ echo "NA";} ?></td>
                    </tr>

                    <tr>
                        <td class="text_view"><b>Entry Fee</b></td>
                        <td>:</td>
                        <td><?php if(!empty($entryFee)){ echo $entryFee; }else{ echo "0";} ?></td>
                        <td class="text_view"><b>Game Mode</b></td>
                        <td>:</td>
                        <td><?php if(!empty($gameMode)){ echo $gameMode; }else{ echo "NA";} ?></td>
                       
                    </tr>

                </tbody>
              </table>
            </div>
              
            <!-- /.box-body -->
          </div>
          <!-- /.box -->
        </div>
        <!-- /.col -->
      </div>
      <!-- /.row -->
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

  <!-- Load common footer -->
<?php $this->load->view('common/footer.php'); ?>
