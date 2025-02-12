-- André Legend the Flame Prince of Valor / 炎の勇者アンドレ / André, le Prince de la Flamme et du Courage
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,2741800,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE))
    
    -- Negate and Banish effects (Quick Effect)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    
    -- Add to hand if leaves the field because of opponent's card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,TYPE_MONSTER)
        and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,TYPE_EQUIP) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,TYPE_MONSTER)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,TYPE_EQUIP)
    g1:Merge(g2)
    Duel.Remove(g1,POS_FACEUP,REASON_COST)
end

function s.costfilter(c,typ)
    return c:IsType(typ) and ((typ == TYPE_MONSTER and c:IsAttribute(ATTRIBUTE_FIRE)) or typ == TYPE_EQUIP) and c:IsAbleToRemoveAsCost()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    e:SetLabel(opt)
    if opt==0 then
        e:SetCategory(CATEGORY_DISABLE)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
    else
        e:SetCategory(CATEGORY_REMOVE)
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local opt=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    if opt==0 then
        local g=Duel.SelectMatchingCard(tp,Card.IsNegatableMonster,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
    else
        local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
            -- Return to the field during the next Standby Phase
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
            e1:SetLabelObject(tc)
            e1:SetCountLimit(1)
            e1:SetCondition(s.retcon)
            e1:SetOperation(s.retop)
            if Duel.GetCurrentPhase()==PHASE_STANDBY then
                e1:SetLabel(Duel.GetTurnCount())
                e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
            else
                e1:SetReset(RESET_PHASE+PHASE_STANDBY)
            end
            Duel.RegisterEffect(e1,tp)
        end
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()~=e:GetLabel()
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    Duel.ReturnToField(tc)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and rp==1-tp
end

function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsType(TYPE_MONSTER+TYPE_SPELL)) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
