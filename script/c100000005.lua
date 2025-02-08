-- Celestial Blue-Eyes Fusion
function c100000005.initial_effect(c)
    -- Fusion or Synchro Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(100000005,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(c100000005.target)
    e1:SetOperation(c100000005.activate)
    c:RegisterEffect(e1)

    -- Unaffected by monster effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetCondition(c100000005.immcon)
    e2:SetValue(c100000005.efilter)
    c:RegisterEffect(e2)

    -- Protect from destruction
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetCondition(c100000005.descon)
    e3:SetCost(aux.bfgcost)
    e3:SetOperation(c100000005.desop)
    c:RegisterEffect(e3)
end

function c100000005.filter1(c,e)
    return not c:IsImmuneToEffect(e)
end

function c100000005.filter2(c,e,tp,m,f,chkf)
    return c:IsType(TYPE_FUSION+TYPE_SYNCHRO) and c:IsSetCard(0xdd)
        and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and m:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99,c)
end

function c100000005.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsAbleToGrave()
            and Duel.GetLocationCountFromEx(tp,tp,Location_MZONE)>0
            and Duel.IsExistingMatchingCard(c100000005.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil,nil,EFFECT_CHAINING)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c100000005.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local chkf = tp
    local mg = Duel.GetFusionMaterial(tp):Filter(c100000005.filter1,nil,e)
    local sg = Duel.GetMatchingGroup(c100000005.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
    if sg:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
            tc:RegisterFlagEffect(100000005,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(100000005,0))
            tc:CompleteProcedure()
            tc:EnableReviveLimit()
            local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
            local sc=Duel.GetMatchingGroup(c100000005.filter1,tp,LOCATION_GRAVE,0,1,e:GetHandler())
            if sc then
                -- Special Summoned Dragon Monster Is Unaffected by Monster Effects
                local e1=Effect.CreateEffect(tc)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_IMMUNE_EFFECT)
                e1:SetValue(c100000005.efilter)
                e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,2)
                tc:RegisterEffect(e1)
            end
        end
    end
end

function c100000005.efilter(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end

function c100000005.immcon(e)
    return e:GetHandler():IsSetCard(0xdd)
end

function c100000005.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.IsExistingMatchingCard(c100000005.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE))
end

function c100000005.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,100000005)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetValue(1)
    e1:SetTarget(c100000005.indtg)
    e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
    Duel.RegisterEffect(e1,tp)
end

function c100000005.indtg(e,c)
    return c:IsSetCard(0xdd) and c:IsType(TYPE_SYNCHRO+TYPE_FUSION) and c:IsSpecialSummoned()
end