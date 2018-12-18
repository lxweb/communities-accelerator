/*
***********************************************************************************************************************************************

Esta estructura permite optimizar la ejecucion de triggers haciendo la menor cantidad de loops posibles de los registros involucrados en un 
trigger, organizando los queries, ejecutando los DMLs en conjunto, evitando recursividad y permitiendo un By Pass atomico a nivel de trigger 
y metodos, y a su vez a nivel de Usuario. Tambien permite activar debug logs para poder trackear y seguir el codigo de manera mas sencilla en
un debug.

La estrucutra de Loops se basa en que solo 2 loops son necesarios para resolver cualquier operacion sobre los registros.

Orden de ejecucion:
1. triggerPreparing: Sirve para hacer filtros sobre el "trigger new/old" o instanciar variales globales a la ejecucion
2. masterLoops: Primer loop de todos los registros involucrados en el trigger
3. dataPreparing: En este metodo seran ejecutados todos los SOQL queries y preparado de colecciones que luego seran usadas en DMLs o finalLoops
4. executeDMLs: En este metodo se ejecutaran todos los DMLs tratando siempre de juntar las colecciones de iguales tipos
5. finalLoops: Segundo y ultimo loop de todos los registros involucrados en el trigger
6. triggerFinish: Sirve para la ejecucion de DMLs que necesitan mas de un loop de los registros en el trigger
7. * selfupdate: Este metodo se ejecutara solo si es necesario actualizar un registro involucrado en el mismo trigger

***********************************************************************************************************************************************
*/


public without sharing virtual class TriggersHandler {
	
    private String triggerName;
    private Boolean allowRecursivity;
    private Boolean runDebugs;

    public Boolean allow_masterLoop_BeforeInsert = false;
    public Boolean allow_masterLoop_AfterInsert = false;
    public Boolean allow_masterLoop_BeforeUpdate = false;
    public Boolean allow_masterLoop_AfterUpdate = false;
    public Boolean allow_masterLoop_BeforeDelete = false;
    public Boolean allow_masterLoop_AfterDelete = false;
    public Boolean allow_masterLoop_AfterUndelete = false;
    public Boolean allow_dataPreparing = false;
    public Boolean allow_executeDMLs = false;
    public Boolean allow_finalLoop_BeforeInsert = false;
    public Boolean allow_finalLoop_BeforeUpdate = false;
    public Boolean allow_finalLoop_AfterInsert = false;
    public Boolean allow_finalLoop_AfterUpdate = false;
    public Boolean allow_finalLoop_BeforeDelete = false;
    public Boolean allow_finalLoop_AfterDelete = false;
    public Boolean allow_finalLoop_AfterUndelete = false;
    public Boolean allow_triggerFinish = false;
    public Boolean allow_selfUpdate = false;

    public List<SObject> triggerNew;
    public List<SObject> triggerOld;

    private map<Id, SObject> mapRecordsToSelfUpdate;
    private Schema.DescribeSObjectResult objDesc;
    
    //CONSTRUCTORS
    public TriggersHandler(List<SObject> p_triggerNew, List<SObject> p_triggerOld, Boolean allowRecursivity) {
        init(p_triggerNew, p_triggerOld, allowRecursivity);
    }

    public TriggersHandler(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        init(p_triggerNew, p_triggerOld, true);
    }

    //INIT METHOD
    private void init(List<SObject> p_triggerNew, List<SObject> p_triggerOld, Boolean allowRecursivity){
        this.allowRecursivity = allowRecursivity;
        mapRecordsToSelfUpdate = new map<Id, SObject>();

		triggerNew = p_triggerNew;
		triggerOld = p_triggerOld;
    }

    //METHODS AVAILABLE TO OVERRIDE
    /*
    public override void triggerPreparing() {}
    public override void masterLoop_BeforeInsert(SObject recNew) {}
    public override void masterLoop_AfterInsert(SObject recNew) {}
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {}
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {}
    public override void masterLoop_BeforeDelete(SObject recOld) {}
    public override void masterLoop_AfterDelete(SObject recOld) {}
    public override void masterLoop_AfterUndelete(SObject recOld) {}
    public override void dataPreparing() {}
    public override void executeDMLs() {}
    public override void finalLoop_BeforeInsert(SObject recNew) {}
    public override void finalLoop_AfterInsert(SObject recNew) {}
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {}
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld) {}
    public override void finalLoop_BeforeDelete(SObject recOld) {}
    public override void finalLoop_AfterDelete(SObject recOld) {}
    public override void finalLoop_AfterUndelete(SObject recNew) {}
    public override void triggerFinish() {}
    public override void selfUpdate() {}
    */

    public void run(){
        triggerName = String.valueOf(this).split(':')[0];

        runDebugs = TriggersHandlerManager.canAutoDebug(triggerName);

        if(runDebugs){system.debug('TRIGGER ' + triggerName);}

        //By Pass
        if(!TriggersHandlerManager.canTrigger(triggerName)){return;}

        if(!allowRecursivity){TriggersHandlerManager.byPassTrigger(triggerName);}

        exeMasterLoops();

        if(!allowRecursivity){TriggersHandlerManager.removeByPassTrigger(triggerName);}
    }

    private void exeMasterLoops() {
        //Ejecucion previa
        triggerPreparingMaster();

        if((trigger.isInsert || trigger.isUpdate || trigger.isUndelete) && trigger.new.isEmpty()){return;}
        if(trigger.isDelete && trigger.old.isEmpty()){return;}

        //Loop principal para impactar datos default en before o recopilar datos en colecciones para operaciones posteriores
        masterLoop(false);

        //Metodo en el que se ejecutan queries y se hace el procesamiento de datos para luego ser impactados
        dataPreparingMaster();

        //Metodo para ejecutar todos los DMLs
        executeDMLsMaster();

        //Loop final para impactar datos
        masterLoop(true);

        //Metodo para ejecutar los DMLs de finalizacion de trigger
        triggerFinishMaster();

        //Metodo para actualizar la misma lista del trigger new
        selfUpdateMaster();
    }

    private void triggerPreparingMaster() {
        triggerPreparing();
    }

    private void masterLoop(Boolean isFinal) {
        
        //Insert loop
        if(allow_masterLoop_BeforeInsert || allow_finalLoop_BeforeInsert || allow_masterLoop_AfterInsert || allow_finalLoop_AfterInsert){
            if(trigger.isInsert){
                for(SObject recNew: (List<SObject>)triggerNew){
                    if(trigger.isBefore){
                        if(!isFinal && allow_masterLoop_BeforeInsert){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE INSERT - MASTER LOOP');}
                            masterLoop_BeforeInsert(recNew);
                        }else if(allow_finalLoop_BeforeInsert){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE INSERT - FINAL LOOP');}
                            finalLoop_BeforeInsert(recNew);
                        }
                    }
                    if(trigger.isAfter){
                        if(!isFinal && allow_masterLoop_AfterInsert){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER INSERT - MASTER LOOP');}
                            masterLoop_AfterInsert(recNew);
                        }else if(allow_finalLoop_AfterInsert){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER INSERT - FINAL LOOP');}
                            finalLoop_AfterInsert(recNew);
                        }
                    }
                }
            }
        }

        //Update loop
        if(allow_masterLoop_BeforeUpdate || allow_finalLoop_BeforeUpdate || allow_masterLoop_AfterUpdate || allow_finalLoop_AfterUpdate){
            if(trigger.isUpdate){
                for(SObject recNew: (List<SObject>)triggerNew){
                    SObject recOld = trigger.oldMap.get(String.valueOf(recNew.get('id')));
                    if(trigger.isBefore){
                        if(!isFinal && allow_masterLoop_BeforeUpdate){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE UPDATE - MASTER LOOP');}
                            masterLoop_BeforeUpdate(recNew, recOld);
                        }else if(allow_finalLoop_BeforeUpdate){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE UPDATE - FINAL LOOP');}
                            finalLoop_BeforeUpdate(recNew, recOld);
                        }
                    }
                    if(trigger.isAfter){
                        if(!isFinal && allow_masterLoop_AfterUpdate){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER UPDATE - MASTER LOOP');}
                            masterLoop_AfterUpdate(recNew, recOld);
                        }else if(allow_finalLoop_AfterUpdate){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER UPDATE - FINAL LOOP');}
                            finalLoop_AfterUpdate(recNew, recOld);
                        }
                    }
                }
            }
        }

        //Delete loop
        if(allow_masterLoop_BeforeDelete || allow_finalLoop_BeforeDelete || allow_masterLoop_AfterDelete || allow_finalLoop_AfterDelete){
            if(trigger.isDelete){
                for(SObject recOld: (List<SObject>)triggerOld){
                    if(trigger.isBefore){
                        if(!isFinal && allow_masterLoop_BeforeDelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE DELETE - MASTER LOOP');}
                            masterLoop_BeforeDelete(recOld);
                        }else if(allow_finalLoop_BeforeDelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE DELETE - FINAL LOOP');}
                            finalLoop_BeforeDelete(recOld);
                        }
                        
                    }
                    if(trigger.isAfter){
                        if(!isFinal && allow_masterLoop_AfterDelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER DELETE - MASTER LOOP');}
                            masterLoop_AfterDelete(recOld);
                        }else if(allow_finalLoop_AfterDelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER DELETE - FINAL LOOP');}
                            finalLoop_AfterDelete(recOld);
                        }
                    }
                }
            }
        }

        //Undelete loop
        if(allow_masterLoop_AfterUndelete || allow_finalLoop_AfterUndelete){
            if(trigger.isUndelete){
                for(SObject recNew: (List<SObject>)triggerNew){
                    if(trigger.isAfter){
                        if(!isFinal && allow_masterLoop_AfterUndelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER UNDELETE - MASTER LOOP');}
                            masterLoop_AfterUndelete(recNew);
                        }else if(allow_finalLoop_AfterUndelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER UNDELETE - FINAL LOOP');}
                            finalLoop_AfterUndelete(recNew);
                        }
                    }
                }
            }
        }

    }

    //QUERIES AND PROCESSING HERE
    private void dataPreparingMaster() {
        if(allow_dataPreparing){
            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - dataPreparing');}
            dataPreparing();
        }
    }

    //DMLs HERE
    private void executeDMLsMaster() {
        if(allow_executeDMLs){
            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - executeDMLs');}
            executeDMLs();
        }
    }

    private void triggerFinishMaster() {
        if(allow_triggerFinish){
            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - triggerFinish');}
            triggerFinish();
        }
    }

    //SELF UPDATE OF TRIGGER NEW HERE
    private void selfUpdateMaster() {
        if(allow_selfUpdate || !mapRecordsToSelfUpdate.values().isEmpty()){
            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - selfUpdate');}
        }
        selfUpdate();
    }

    //METHODS AVAILABLE TO OVERRIDE
    public virtual void triggerPreparing() {}

    public virtual void masterLoop_BeforeInsert(SObject recNew) {}
    public virtual void masterLoop_AfterInsert(SObject recNew) {}
    public virtual void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {}
    public virtual void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {}
    public virtual void masterLoop_BeforeDelete(SObject recOld) {}
    public virtual void masterLoop_AfterDelete(SObject recOld) {}
    public virtual void masterLoop_AfterUndelete(SObject recOld) {}

    public virtual void dataPreparing() {}

    public virtual void executeDMLs() {}

    public virtual void finalLoop_BeforeInsert(SObject recNew) {}
    public virtual void finalLoop_AfterInsert(SObject recNew) {}
    public virtual void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {}
    public virtual void finalLoop_AfterUpdate(SObject recNew, SObject recOld) {}
    public virtual void finalLoop_BeforeDelete(SObject recOld) {}
    public virtual void finalLoop_AfterDelete(SObject recOld) {}
    public virtual void finalLoop_AfterUndelete(SObject recNew) {}

    public virtual void triggerFinish() {}

    public virtual void selfUpdate() {
        if(!mapRecordsToSelfUpdate.values().isEmpty()){
            update mapRecordsToSelfUpdate.values();
        }
    }

    //UTIL METHODS
    public Boolean canMethod(String method){
        Boolean allowMethod = TriggersHandlerManager.canTrigger(triggerName + '.' + method);
        if(allowMethod){
            if(runDebugs){system.debug('TRIGGER METHOD ' + triggerName + '.' + method);}
        }
        return allowMethod;
    }

    public void recordSelfUpdate(Id recId, String fieldApiName, Object value){
        if(objDesc == null){
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(String.ValueOf(recId.getsobjecttype()));
            objDesc = objType.getDescribe();
        }

        SObject recClone;
        if(mapRecordsToSelfUpdate.containsKey(recId)){
            recClone = mapRecordsToSelfUpdate.get(recId);
            setFieldValueOnRecord(recClone, fieldApiName, value);
        }else{
            recClone = (SObject)Type.forName(String.ValueOf(recId.getsobjecttype())).newInstance();
            recClone.put('Id', recId);
            setFieldValueOnRecord(recClone, fieldApiName, value);
        }
        mapRecordsToSelfUpdate.put(recId, recClone);
    }

    private void setFieldValueOnRecord(SObject rec, String fieldApiName, Object value){
        Schema.DescribeFieldResult field = objDesc.fields.getMap().get(fieldApiName).getDescribe();
        Schema.SOAPType soapType = field.getSOAPType();
        if(soapType == Schema.SOAPType.String || soapType == Schema.SOAPType.anytype || soapType == Schema.SOAPType.ID ) {
            rec.put(fieldApiName, String.ValueOf(value));
        } else if ( soapType == Schema.SOAPType.Integer ){
            rec.put(fieldApiName, Long.valueOf(String.ValueOf(value)));
        } else if ( soapType == Schema.SOAPType.Boolean ){
            rec.put(fieldApiName, Boolean.ValueOf(value));
        } else if ( soapType == Schema.SOAPType.Date ){
            rec.put(fieldApiName, Date.ValueOf(value));
        } else if ( soapType == Schema.SOAPType.DateTime ){
            rec.put(fieldApiName, Datetime.valueOf(value));
        } else if ( soapType == Schema.SOAPType.Double ){
            rec.put(fieldApiName, Double.ValueOf(value));
        } else if ( soapType == Schema.SOAPType.base64binary ){
            rec.put(fieldApiName, Blob.ValueOf(String.ValueOf(value)));
        }
    }

}