<!-- Load common header -->
<?php $this->load->view('common/header'); ?>

<!-- Load common left panel -->
<?php $this->load->view('common/left_panel'); ?>

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
              <div class="col-md-8 box-title"><?= $heading; ?></div>
              <div class="col-md-4 text-right text-danger">* Fields are required</div>
            </div>
            <!-- /.box-header -->
              <?= form_open($action)?>
              <div class="box-body">
                <div class="form-group col-md-6">
                  <label>Tournament Title<span class="text-danger"> * </span> <span id="err_tournamentTitle" class="text-danger"><?= strip_tags(form_error('tournamentTitle'));?></span></label>
                  <input type="text" class="form-control" name="tournamentTitle" id="tournamentTitle" placeholder="Enter Tournament Title" value="<?= $tournamentTitle;?>" autocomplete="off">
                </div>

                <div class="form-group col-md-6">
                  <label>Start Date<span class="text-danger"> * </span><span id="err_startDate" class="text-danger"><?= strip_tags(form_error('startDate'));?></span></label>
                  <input type="text" class="form-control datepicker" name="startDate" id="startDate" placeholder="Enter Start Date" value="<?= $startDate;?>" onkeypress="return only_number(event)" autocomplete="off" readonly>
                </div>

                <div class="form-group col-md-6">
                  <label>Start Time<span class="text-danger"> * </span><span id="err_startTime" class="text-danger"><?= strip_tags(form_error('startTime'));?></span></label>
                  <input type="text" class="form-control timePick" name="startTime" id="startTime" placeholder="Enter Start Time" value="<?= $startTime;?>" onkeypress="return only_number(event)" autocomplete="off" readonly>
                </div>

                <div class="form-group col-md-6">
                  <label>Description<span class="text-danger"> * </span><span id="err_tournamentDescription" class="text-danger"><?= strip_tags(form_error('tournamentDescription'));?></span></label>
                  <textarea class="form-control" name="tournamentDescription" id="tournamentDescription"><?= $tournamentDescription;?></textarea>  
                </div>

              <!--   <div class="form-group col-md-6">
                  <label>Winning Price<span class="text-danger"> * </span><span id="err_winningPrice" class="text-danger"><?= strip_tags(form_error('winningPrice'));?></span></label>
                  <input type="text" class="form-control" name="winningPrice" id="winningPrice" placeholder="Enter Winning Price" value="<?= $winningPrice;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div> -->
                  <input type="hidden" class="form-control" name="winningPrice" id="winningPrice" placeholder="Enter Winning Price" value="<?= $winningPrice;?>" onkeypress="return only_number(event)" autocomplete="off">

                <div class="form-group col-md-6">
                  <label>Player Limit In Room 
                    <span class="text-danger"> * </span> <span id="err_playerLimitInRoom" class="text-danger"><?= strip_tags(form_error('playerLimitInRoom'));?></span>
                  </label>
                <!--   <input type="text" class="form-control" name="playerLimitInRoom" id="playerLimitInRoom" placeholder="Player Limit In Room" value="<?= $playerLimitInRoom; ?>" onkeypress="return only_number(event)" autocomplete="off"> -->
                    <select class="form-control" name="playerLimitInRoom" id="playerLimitInRoom"  >
                      <option value="2" <?php if($playerLimitInRoom=="2"){ echo "selected"; }?>>Two</option>
                      <option value="4" <?php if($playerLimitInRoom=="4"){ echo "selected"; }?>>Four</option>
                    </select>
                </div>

                <div class="form-group col-md-6">
                  <label>No Of Round In Tournament <span class="text-danger"> * </span><span id="err_noOfRound" class="text-danger"><?= strip_tags(form_error('noOfRoundInTournament'));?></span></label>
                  <input type="text" class="form-control" name="noOfRoundInTournament" id="noOfRoundInTournament" placeholder="Enter No Of Round In Tournament" value="<?= $noOfRoundInTournament;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>

                <div class="form-group col-md-6">
                  <label>Player Limit In Tournament <span class="text-danger"> * </span><span id="err_playerLimitInTournament" class="text-danger"><?= strip_tags(form_error('playerLimitInTournament'));?></span></label>
                  <input type="text" class="form-control" name="playerLimitInTournament" id="playerLimitInTournament" placeholder="Enter Player Limit In Tournament" value="<?= $playerLimitInTournament;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>

                 <div class="col-md-6">
                  <div class="form-group">
                    <label>Commision In % <span class="text-danger"> * </span><span id="err_commision" class="text-danger"><?= strip_tags(form_error('commision'));?></span></label>
                    <input type="text" class="form-control" name="commision" id="commision" placeholder="Commision In %" value="<?= $commision; ?>" onkeypress="return only_number(event)" autocomplete="off"  oninput="bigBlindValue(this.value)">
                  </div> 
                </div>

                <div class="col-md-6">
                  <div class="form-group">
                    <label>Start Round Time<span class="text-danger"> * </span><span id="err_startRoundTime" class="text-danger"><?= strip_tags(form_error('startRoundTime'));?></span></label>
                    <input type="text" class="form-control" name="startRoundTime" id="startRoundTime" placeholder=" Enter Start Round Time" value="<?= $startRoundTime; ?>" onkeypress="return only_number(event)"  autocomplete="off">
                  </div> 
                </div>
 <!-- <input type="hidden" class="form-control" name="startRoundTime" id="startRoundTime" placeholder=" Enter Start Round Time" value="1" onkeypress="return only_number(event)"  autocomplete="off"> -->
                <!-- <div class="col-md-6">
                  <div class="form-group">
                    <label>Token Move Time<span class="text-danger"> * </span><span id="err_tokenMoveTime" class="text-danger"><?= strip_tags(form_error('tokenMoveTime'));?></span></label>
                    <input type="text" class="form-control" name="tokenMoveTime" id="tokenMoveTime" placeholder="Enter Token Move Time" value="<?= $tokenMoveTime; ?>" onkeypress="return only_number(event)" autocomplete="off">
                  </div> 
                </div>  -->
                 <input type="hidden" class="form-control" name="tokenMoveTime" id="tokenMoveTime" placeholder="Enter Token Move Time" value="1" onkeypress="return only_number(event)" autocomplete="off">
                <!-- <div class="col-md-6">
                  <div class="form-group">
                    <label>Roll Dice Time<span class="text-danger"> * </span><span id="err_rollDiceTime" class="text-danger"><?= strip_tags(form_error('rollDiceTime'));?></span></label>
                    <input type="text" class="form-control" name="rollDiceTime" id="rollDiceTime" placeholder="Enter Roll Dice Time" value="<?= $rollDiceTime; ?>" onkeypress="return only_number(event)" autocomplete="off">
                  </div> 
                </div> -->
                 <input type="hidden" class="form-control" name="rollDiceTime" id="rollDiceTime" placeholder="Enter Roll Dice Time" value="1" onkeypress="return only_number(event)" autocomplete="off">
                <div class="col-md-6">
                  <div class="form-group">
                    <label>Entry Fee<span class="text-danger"> * </span><span id="err_entryFee" class="text-danger"><?= strip_tags(form_error('entryFee'));?></span></label>
                    <input type="text" class="form-control" name="entryFee" id="entryFee" placeholder="Enter Entry Fee" value="<?= $entryFee; ?>" onkeypress="return only_number(event)"  autocomplete="off">
                  </div> 
                </div>

                <div class="col-md-6">
                  <div class="form-group">
                    <label>Game Mode<span class="text-danger"> * </span><span id="err_gameMode" class="text-danger"><?= strip_tags(form_error('gameMode'));?></span></label>
                    <select class="form-control" name="gameMode" id="gameMode" placeholder="Enter Entry Fee" value="<?= $gameMode; ?>" >
                      <option value="">Select Game Mode</option>
                      <option value="Quick"<?php if($gameMode=="Quick"){ echo "selected"; }else{ echo "";}?>>Quick</option>
                      <option value="Classic"<?php if($gameMode=="Classic"){ echo "selected"; }else{ echo "";}?>>Classic</option>
                    </select>
                  </div> 
                </div>

              </div>
            
          </div>
          <div class="box bShow">
             <div class="box-header with-border">
              <div class="col-md-8 box-title">Winner Price Distribution</div>
            </div>
            <div class="box-body">
                <div class="form-group col-md-6">
                  <label>First Winner<span class="text-danger"> * </span> <span id="err_firstRoundWinner" class="text-danger"><?= strip_tags(form_error('firstRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="firstRoundWinner" id="firstRoundWinner" placeholder="Enter First Winner" value="<?= $firstRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Second Winner<span class="text-danger">  </span> <span id="err_secondRoundWinner" class="text-danger"><?= strip_tags(form_error('secondRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="secondRoundWinner" id="secondRoundWinner" placeholder="Enter Tournament Title" value="<?= $secondRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Third Winner<span class="text-danger">  </span> <span id="err_thirdRoundWinner" class="text-danger"><?= strip_tags(form_error('thirdRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="thirdRoundWinner" id="thirdRoundWinner" placeholder="Enter Third Winner" value="<?= $thirdRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Fourth Winner<span class="text-danger">  </span> <span id="err_fouthRoundWinner" class="text-danger"><?= strip_tags(form_error('fouthRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="fouthRoundWinner" id="fouthRoundWinner" placeholder="Enter Fourth Winner" value="<?= $fouthRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Fifth Winner<span class="text-danger">  </span> <span id="err_fivethRoundWinner" class="text-danger"><?= strip_tags(form_error('fivethRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="fivethRoundWinner" id="fivethRoundWinner" placeholder="Enter Fifth Winner" value="<?= $fivethRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Sixth Winner<span class="text-danger">  </span> <span id="err_sixthRoundWinner" class="text-danger"><?= strip_tags(form_error('sixthRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="sixthRoundWinner" id="sixthRoundWinner" placeholder="Enter Sixth Winner" value="<?= $sixthRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Seventh Winner<span class="text-danger">  </span> <span id="err_seventhRoundWinner" class="text-danger"><?= strip_tags(form_error('seventhRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="seventhRoundWinner" id="seventhRoundWinner" placeholder="Enter Seventh Winner" value="<?= $seventhRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Eigth Winner<span class="text-danger">  </span> <span id="err_eightRoundWinner" class="text-danger"><?= strip_tags(form_error('eightRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="eightRoundWinner" id="eightRoundWinner" placeholder="Enter Eigth Winner" value="<?= $eightRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Nineth Winner<span class="text-danger">  </span> <span id="err_ninethRoundWinner" class="text-danger"><?= strip_tags(form_error('ninethRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="ninethRoundWinner" id="ninethRoundWinner" placeholder="Enter Nineth Winner" value="<?= $ninethRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                <div class="form-group col-md-6">
                  <label>Tenth Winner<span class="text-danger">  </span> <span id="err_tenthRoundWinner" class="text-danger"><?= strip_tags(form_error('tenthRoundWinner'));?></span></label>
                  <input type="text" class="form-control" name="tenthRoundWinner" id="tenthRoundWinner" placeholder="Enter Tenth Winner" value="<?= $tenthRoundWinner;?>" onkeypress="return only_number(event)" autocomplete="off">
                </div>
                
                

            </div>
          </div>
          <div class="box bShow">
             <div class="box-body">
              <div class="box-footer">
                  <input type="hidden" name="button" id="button" value="<?= $button; ?>">
                  <input type="hidden" name="tournamentId" value="<?= $tournamentId; ?>">
                  <button type="submit" class="btn btn-success btn-sm" onclick="return Validate();"><?= $button; ?></button>&nbsp;
                  <a href="<?= site_url(TOURNAMENTS); ?>"><button type="button" class="btn btn-danger btn-sm">CANCEL</button></a>
              </div>
            </div>
          </div>
              <!-- /.box-body -->
            <?= form_close();?>
            <!-- /.box-body -->
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
<!--   <script src="jquery.datetimepicker.js"></script> -->
<?php $this->load->view('common/footer'); ?>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/2.3.0/socket.io.js"></script>
<script type="text/javascript" src="<?= base_url(); ?>assets/custom_js/tournament.js"></script>
