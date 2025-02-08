--ブルーアイズサプライズ
--Blue-Eyes Surprise!
local s,id=GetID()
-- List the names of referenced cards
s.listed_names={CARD_BLUEEYES_W_DRAGON}

function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.fusionfilter(c)
    return c:IsMonster() and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and c:IsRace(RACE_DRAGON)
end

function s.synchrofilter(c)
    return c:IsMonster() and (c:IsType(TYPE_TUNER) or not c:IsType(TYPE_TUNER)) and c:IsAbleToRemove() and c:HasLevel()
end

function s.blueeyes_filter(c)
    return c:IsCode(89631139) and c:IsAbleToRemove()
end

function s.blueeyes_synchro_filter(c,e,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.dragon_fusion_filter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAbleToRemove()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.blueeyes_level8_filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.level1_tuner_filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    if opt==0 then
        -- Fusion Summon
        s.fusion(e,tp,eg,ep,ev,re,r,rp)
    else
        -- Synchro Summon (Blue-Eyes only)
        s.blueeyes_synchro(e,tp,eg,ep,ev,re,r,rp)
    end
end

function s.fusionsummonfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

function s.synchrosummonfilter(c,e,tp)
    local tuners=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
    local nonTuners=Duel.GetMatchingGroup(s.nontunerfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
    return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
        and s.matchingSynchroLevel(tuners,nonTuners,c:GetLevel())
end

function s.matchingSynchroLevel(tuners,nonTuners,level)
    return tuners:IsExists(function(tuner)
        return nonTuners:IsExists(function(nonTuner)
            return nonTuner:IsSetCard(0xdd) and tuner:GetLevel() + nonTuner:GetLevel() == level
        end, 1, nil)
    end, 1, nil) or tuners:IsExists(function(tuner1)
        return tuners:IsExists(function(tuner2)
            return nonTuners:IsExists(function(nonTuner)
                return nonTuner:IsSetCard(0xdd) and tuner1:GetLevel() + tuner2:GetLevel() + nonTuner:GetLevel() == level
            end, 1, tuner1)
        end, 1, tuner1)
    end, 1, nil)
end

function s.fusion(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.fusionsummonfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local sc=sg:GetFirst()
    if not sc then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.blueeyes_filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
    if #g==0 then return end
    local g2=Duel.SelectMatchingCard(tp,s.dragon_fusion_filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,g:GetFirst())
    if #g2==0 then return end
    g:Merge(g2)
    if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 then
        Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
        if g:IsExists(Card.IsCode,1,nil,89631139) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_IMMUNE_EFFECT)
            e1:SetValue(s.efilter)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            sc:RegisterEffect(e1)
        end
    end
end

function s.blueeyes_synchro(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.blueeyes_synchro_filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local sc=sg:GetFirst()
    if not sc then return end
    local lv=sc:GetLevel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.tunerfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,2,nil)
    if #g1==0 then return end
    local tuner=g1:GetFirst()
    local lv_remain=lv-tuner:GetLevel()
    if #g1==2 then
        local tuner2=g1:GetNext()
        lv_remain=lv_remain-tuner2:GetLevel()
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,s.nontunerfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,lv_remain)
    if #g2==0 or lv_remain~=g2:GetFirst():GetLevel() then return end
    local nonTuner=g2:GetFirst()
    local mg=Group.FromCards(tuner,nonTuner)
    if #g1==2 then mg:AddCard(tuner2) end
    if mg:GetCount()==2 and mg:GetSum(Card.GetLevel)==lv then
        if Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)==mg:GetCount() then
            Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
            sc:CompleteProcedure()
            if mg:IsExists(Card.IsCode,1,nil,89631139) then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_IMMUNE_EFFECT)
                e1:SetValue(s.efilter)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                sc:RegisterEffect(e1)
            end
        end
    end
end

function s.tunerfilter(c)
    return c:IsMonster() and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end

function s.nontunerfilter(c)
    return c:IsMonster() and not c:IsType(TYPE_TUNER) and c:IsSetCard(0xdd) and c:IsAbleToRemove() and c:HasLevel()
end

function s.efilter(e,te)
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end