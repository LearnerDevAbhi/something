<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class TournamentsUsersHistory_model extends CI_Model
{
	var $column_order = array(null,'tr.tournamentTitle','tr.userName','tr.entryFee','tr.round','tr.roundStatus','tr.playerLimitInRoom','tr.startDate','tr.startTime',null); //set column field database for datatable orderable
    var $column_search = array('t.tournamentTitle','tr.userName','tr.entryFee','tr.roundStatus','tr.round','tr.playerLimitInRoom','tr.startDate'); //set column field database for datatable searchable 
    var $order = array('tr.tournamentWinLossLogId' => 'DESC'); 

    function __construct()
    {
        parent::__construct();
    }
	
	private function _get_datatables_query($table,$condition='')
	{
        $this->db->select('tr.*');
		$this->db->from($table);        
		 $i = 0;

         if(!empty($condition))
            $this->db->where($condition);

    
        foreach ($this->column_search as $item) // loop column 
        {
            if($_POST['search']['value']) // if datatable send POST for search
            {
                
                if($i===0) // first loop
                {
                    $this->db->group_start(); // open bracket. query Where with OR clause better with bracket. because maybe can combine with other WHERE with AND.
                    $this->db->like($item, $_POST['search']['value']);
                }
                else
                {
                    $this->db->or_like($item, $_POST['search']['value']);
                }

                if(count($this->column_search) - 1 == $i) //last loop
                    $this->db->group_end(); //close bracket
            }
            $i++;
        }
        
        if(isset($_POST['order'])) // here order processing
        {
            $this->db->order_by($this->column_order[$_POST['order']['0']['column']], $_POST['order']['0']['dir']);
        } 
        else if(isset($this->order))
        {
            $order = $this->order;
            $this->db->order_by(key($order), $order[key($order)]);
        }
    }

	function get_datatables($table,$condition='')
    {
        $this->_get_datatables_query($table,$condition);
        if($_POST['length'] != -1)
        $this->db->limit($_POST['length'], $_POST['start']);
        $query = $this->db->get();
        return $query->result();
    }

	public function count_all($table,$condition='')
    {    
        $this->db->select('sw.*');
        $this->db->from($table,$condition);
        if(!empty($condition))
            $this->db->where($condition);
        return $this->db->count_all_results();
    }


	function count_filtered($table,$condition='')
    {
        $this->_get_datatables_query($table,$condition);
        $query = $this->db->get();
        return $query->num_rows();
    }

    public function GetData($table,$field='',$condition='',$group='',$order='',$limit='',$result='')
    {
        if($field != '')
            $this->db->select($field);
        if($condition != '')
            $this->db->where($condition);
        if($order != '')
            $this->db->order_by($order);
        if($limit != '')
            $this->db->limit($limit);
        if($group != '')
            $this->db->group_by($group);
        if($result != '')
        {
            $return =  $this->db->get($table)->row();
        }else{
            $return =  $this->db->get($table)->result();
        }
        return $return;
    }

    public function SaveData($table,$data='',$condition='')
    {
        $DataArray = array();
        if(!empty($data))
        { 
            if(!empty($condition))
            {
                $data['modified']=date("Y-m-d H:i:s");
            }
            else
            {
                $data['created']=date("Y-m-d H:i:s");
                $data['modified']=date("Y-m-d H:i:s");
            }
        }
        $table_fields = $this->db->list_fields($table);
        foreach($data as $field=>$value)
        {
            if(in_array($field,$table_fields))
            {
                $DataArray[$field]= $value;
            }
        }

        if($condition != '')
        {
            $this->db->where($condition);
            $this->db->update($table, $DataArray);

        }else{
            $this->db->insert($table, $DataArray);
        }
    }

    public function DeleteData($table,$condition='',$limit='')
    {
        if($condition != '')
            $this->db->where($condition);
        if($limit != '')
            $this->db->limit($limit);
        $this->db->delete($table);
    }
}